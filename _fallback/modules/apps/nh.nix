{ inputs, self, ... }:
{

  flake.nixosModules.nh =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      username = config.preferences.user.name;
      flakePath = "/home/${username}/.dotfiles/_fallback";
    in
    {

      programs.nh = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.nh;
        clean = {
          enable = true;
          extraArgs = "--keep-since 2d --keep 2";
        };
        flake = lib.mkDefault flakePath;
      };

      environment.systemPackages = with pkgs; [
        nix-output-monitor
        nvd
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.nh = inputs.wrappers.lib.wrapPackage [
        inputs.wrappers.wrapperModules.nh
        {
          inherit pkgs;
          nom = true;
          flake = "/home/artifex/.dotfiles/_fallback";
          runtimePkgs = with pkgs; [
            nix-output-monitor
            nvd
          ];
        }
      ];
    };

}
