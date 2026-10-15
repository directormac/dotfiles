# Gaming Role: gaming runtimes, Steam, Wine, overlays, and dynamic linker helpers
{ den, ... }:
{
  den.aspects.roles.gaming = {
    includes = with den.aspects; [
      hardware.steam-hardware
      applications.gaming.nix-ld
      applications.gaming.steam
      applications.gaming.mangohud
      applications.gaming.gamescope
      applications.gaming.gamemode
      applications.gaming.lutris
      applications.gaming.heroic
      applications.gaming.bottles
    ];
  };

  # Backward compatibility aliases
  den.aspects.gaming.includes = [ den.aspects.roles.gaming ];
}
