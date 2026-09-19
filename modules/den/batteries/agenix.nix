{
  den,
  inputs,
  rootPath,
  lib,
  config,
  ...
}: let
  agenixGeneratorsModule = import ../aspects/secrets/_generators-module.nix;

  agenixHostAspect = {
    host,
    secretsConfig ? config.den.secretsConfig,
    ...
  }: let
    hasImpermanence = host.hasAspect den.aspects.base.impermanence;
    persistPrefix = lib.optionalString hasImpermanence "/persist";
  in {
    name = "agenix/${host.name}";
    ${host.class} =
      if host.class == "droid"
      then {}
      else
        {
          config,
          lib,
          ...
        }: {
          imports = [
            inputs.agenix."${host.class}Modules".default
            inputs.agenix-rekey."${host.class}Modules".default
            agenixGeneratorsModule
          ];

          age = {
            identityPaths = [
              "${persistPrefix}/etc/ssh/ssh_host_ed25519_key"
            ];

            rekey = {
              inherit (secretsConfig) masterIdentities;
              storageMode = "local";
              hostPubkey = builtins.readFile host.public_key;
              generatedSecretsDir = host.secretPath + "/generated";
              localStorageDir = host.secretPath + "/rekeyed";
            };
          };

          system.activationScripts = lib.mkIf (host.class == "nixos" && config.age.secrets != {}) {
            removeAgenixLink.text = "[[ ! -L /run/agenix ]] && [[ -d /run/agenix ]] && rm -rf /run/agenix";
            agenixNewGeneration.deps = ["removeAgenixLink"];
          };

          _module.args.secrets = lib.mapAttrs (_: v: v.path) config.age.secrets;
        };
  };

  agenixUserAspect = {
    user,
    host,
    secretsConfig ? config.den.secretsConfig,
    ...
  }: {
    name = "agenix-identity/${user.name}@${host.name}";

    homeManagerModules = {inputs', ...}: [
      inputs'.agenix.homeManagerModules.default
      inputs'.agenix-rekey.homeManagerModules.default
      agenixGeneratorsModule
      (
        {
          config,
          lib,
          ...
        }: {
          _module.args.secrets = lib.mapAttrs (_: v: v.path) config.age.secrets;
        }
      )
    ];

    ${host.class} =
      if host.class == "droid"
      then (_: {})
      else
        _: {
          age.secrets."user-identity-${user.name}" = {
            rekeyFile = rootPath + "/.secrets/users/${user.name}/id_agenix.age";
            owner = user.name;
            group = user.name;
            mode = "600";
            generator.script = "age-identity";
          };
        };
    homeManager = {osConfig, ...}: let
      hasOsAge = osConfig ? age;
      hasUserIdentity = hasOsAge && osConfig.age.secrets ? "user-identity-${user.name}";
      userPubkeyPath = rootPath + "/.secrets/users/${user.name}/id_agenix.pub";
    in {
      age = {
        identityPaths = lib.optionals hasUserIdentity [
          osConfig.age.secrets."user-identity-${user.name}".path
        ];

        rekey = {
          inherit (secretsConfig) masterIdentities;
          storageMode = "local";
          generatedSecretsDir = rootPath + "/.secrets/generated/${user.name}/${host.name}";
          localStorageDir = rootPath + "/.secrets/rekeyed/${user.name}/${host.name}";
          hostPubkey =
            if hasUserIdentity
            then userPubkeyPath
            else if hasOsAge
            then osConfig.age.rekey.hostPubkey
            else userPubkeyPath;
        };
      };
    };
  };
in {
  # The inputs are defined in flake-file.nix as per our previous step.
  # So we only import the flake modules and set up the battery here.
  imports = [
    inputs.agenix-rekey.flakeModule
  ];

  den.schema.host.includes = [agenixHostAspect];
  den.schema.user.includes = [agenixUserAspect];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    agenix-rekey = {
      # nixosConfigurations = inputs.self.outputs.nixosConfigurations;
      # collectHomeManagerConfigurations = true;
    };

    devenv.shells.default = {
      packages = [
        pkgs.age
        config.agenix-rekey.package
      ];
      env = {
        AGENIX_REKEY_ADD_TO_GIT = "true";
      };
    };
  };
}
