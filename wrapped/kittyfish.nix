{
  lib,
  inputs,
  self,
  ...
}:
{

  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      packages = {
        fishell = inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = self'.packages.fish;
          runtimePkgs = [
            pkgs.kitty-img
          ];
          env = {
            EDITOR = lib.getExe pkgs.neovim;
          };
        };

        # kittyfish =
        #   (inputs.wrappers.wrapperModules.kitty.apply {
        #     inherit pkgs;
        #     imports = [ self.wrappersModules.kitty ];
        #     shell = lib.getExe self'.packages.fishell;
        #   }).wrapper;

        kittyfish =
          inputs.wrappers.wrappers.kitty.wrap {
            inherit pkgs;
            dynamicMode = true;
            imports = [ self.wrappersModules.kitty ];
            shell = lib.getExe self'.packages.fishell;
          };

        nix-check-bin = pkgs.writeShellApplication {
          name = "nix-check-bin";
          text = ''
            $EDITOR "$(nix build "$1" --no-link --print-out-paths)/bin"
          '';
        };
      };
    };
}
