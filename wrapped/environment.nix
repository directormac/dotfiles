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
        # My primary flake terminal
        kittyfish =
          (inputs.lwrappers.wrapperModules.kitty.apply {
            inherit pkgs;
            imports = [ self.wrappersModules.kitty ];
            shell = lib.getExe self'.packages.environment;
          }).wrapper;

        # Fish kitty
        environment = inputs.lwrappers.lib.wrapPackage {
          inherit pkgs;
          package = self'.packages.fish;
          runtimeInputs = (inputs.self.commonShellPkgs pkgs self') ++ [
            # nix
            pkgs.nil
            pkgs.nixd
            pkgs.statix
            pkgs.manix
            pkgs.nix-inspect
            self'.packages.nh

            # other
            pkgs.file
            pkgs.unzip
            pkgs.zip
            pkgs.p7zip
            pkgs.wget
            pkgs.killall
            pkgs.sshfs
            pkgs.fzf
            pkgs.htop
            pkgs.fastfetch
            pkgs.tree-sitter
            pkgs.imagemagick
            pkgs.imv
            pkgs.ffmpeg-full
            pkgs.yt-dlp

            # wrapped
            self'.packages.qalc
            self'.packages.lf
            self'.packages.nix-check-bin
          ];
          env = {
            EDITOR = lib.getExe pkgs.neovim;
          };
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
