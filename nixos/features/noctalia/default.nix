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
      packages.noctalia = inputs.wrappers.lib.wrapPackage (
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
