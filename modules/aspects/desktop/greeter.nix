# Display Manager & Greeter Aspect
{
  core,
  inputs,
  lib,
  ...
}:
{
  core.greeter = {
    nixos =
      { pkgs, lib, ... }:
      {
        services.displayManager.sddm = {
          enable = lib.mkDefault true;
          wayland.enable = lib.mkDefault true;
          autoNumlock = true;
          package = pkgs.kdePackages.sddm;
        };
      };
  };

  # Attach to workstation aspect
  core.workstation.includes = [
    core.greeter
  ];
}
