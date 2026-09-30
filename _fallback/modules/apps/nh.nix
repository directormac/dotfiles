{ inputs, ... }:
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

  perSystem = { pkgs, ... }: {
    packages.nh = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.nh;
    };
  };

}
