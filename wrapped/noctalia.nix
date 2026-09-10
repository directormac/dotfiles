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
      packages.noctalia = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.noctalia;
        env = {
          # Use the home-manager symlink location instead of the Nix store
          NOCTALIA_CONFIG_HOME = "$HOME/.config/noctalia";
        };
      };
    };
}
