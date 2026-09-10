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

    # Enable UWSM globally or via the compositor option
    programs.uwsm.enable = true;

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };

  perSystem = { pkgs, self', ... }: {
    packages.hyprland = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.hyprland;

    };
  };
}
