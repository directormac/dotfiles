{
  inputs,
  self,
  ...
}:
{
  flake.nixosModules.hyprland = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.dms
    ];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };
  };

  perSystem = { pkgs, self', ... }: {
    packages.hyprland = inputs.lwrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.hyprland;

    };
  };
}
