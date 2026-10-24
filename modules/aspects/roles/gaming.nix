# Gaming Role: gaming runtimes, Steam, Wine, overlays, and dynamic linker helpers
{ den, ... }:
{
  den.aspects.roles.gaming = {
    includes = with den.aspects.applications.gaming; [
      extra-peripherals
      nix-ld
      steam
      mangohud
      gamescope
      gamemode
      lutris
      heroic
      bottles
    ];
  };
}
