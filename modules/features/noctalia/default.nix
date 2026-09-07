# { self, inputs, ... }: {
#
#   flake.nixosModules.noctalia = { pkgs, lib, ... }: {
#     programs.noctalia = {
#       enable = true;
#     };
#   };
#
#   # perSystem = { pkgs, ... }: {
#   #
#   #
#   #
#   # };
#
#   #  perSystem = { pkgs, ... }: {
#   #    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia.wrap {
#   # inherit pkgs;
#   # # settings =
#   # #     (builtins.fromTOML
#   # # 	(builtins.readFile ./noctalia.toml));
#   # settings = {
#   #
#   #
#   # };
#   #    };
#   #  };
# }

{
  self,
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.noctalia = inputs.wrapper-modules.lib.wrapPackage (
        {
          config,
          wlib,
          lib,
          ...
        }:
        let
          # Create a directory structure in the Nix store: $out/noctalia/config.toml
          configDir = pkgs.runCommand "noctalia-config-dir" { } ''
            mkdir -p $out/noctalia
            # We copy your local file into the store, naming it config.toml
            cp ${./noctalia.toml} $out/noctalia/config.toml
          '';
        in
        {
          inherit pkgs;
          package = pkgs.noctalia;
          # Set the custom environment variable defined in Noctalia's docs
          env = {
            NOCTALIA_CONFIG_HOME = "${configDir}";
          };
        }
      );
    };
}
