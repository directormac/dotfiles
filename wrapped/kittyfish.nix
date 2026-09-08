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
        fishell = inputs.lwrappers.lib.wrapPackage {
          inherit pkgs;
          package = self'.packages.fish;
          runtimeInputs = (inputs.self.commonShellPkgs pkgs self') ++ [
            pkgs.kitty-img
          ];
          env = {
            EDITOR = lib.getExe pkgs.neovim;
          };
        };

        # kittyfish =
        #   (inputs.lwrappers.wrapperModules.kitty.apply {
        #     inherit pkgs;
        #     imports = [ self.wrappersModules.kitty ];
        #     shell = lib.getExe self'.packages.fishell;
        #   }).wrapper;

        kittyfish =
          (inputs.lwrappers.wrapperModules.kitty.apply {
            inherit pkgs;
            dynamicMode = true;
            imports = [ self.wrappersModules.kitty ];
            shell = lib.getExe self'.packages.fishell;
          }).wrapper;

        nix-check-bin = pkgs.writeShellApplication {
          name = "nix-check-bin";
          text = ''
            $EDITOR "$(nix build "$1" --no-link --print-out-paths)/bin"
          '';
        };
      };
    };
}
