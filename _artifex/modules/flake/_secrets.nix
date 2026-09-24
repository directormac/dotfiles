{ inputs, ... }: {
  flake-file.inputs = {
    agenix.url = "github:ryantm/agenix";
    agenix-rekey.url = "github:sini/agenix-rekey/feat/settings";
    agenix-rekey-to-sops.url = "github:sini/agenix-rekey-to-sops";
    # agenix-shell.url = "github:aciceri/agenix-shell";
  };

  imports = [
    # inputs.agenix-shell.flakeModules.default

    inputs.agenix-rekey.flakeModule
    inputs.agenix-rekey-to-sops.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      agenix-rekey = {
        collectHomeManagerConfigurations = true;
        extraConfigurations = { };
        nixosConfigurations = inputs.self.outputs.nixosConfigurations;
      };

      devenv.shells.default = {
        env = {
          AGENIX_REKEY_ADD_TO_GIT = "true";
        };

        packages = [
          pkgs.age
        ];

        scripts = {
          sops-rekey = {
            description = "Edit, generate, rekey secrets, and generate SOPS files";
            exec = "${config.agenix-rekey-sops.package}/bin/agenix-rekey-sops";
          };
        };
      };
    };
}
