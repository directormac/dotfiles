# Quirks declaration: open-ended structured channels for aspect data emission
{
  den.quirks.autostart = {
    description = "Session autostart desktop entries and commands";
  };

  den.quirks.cache = {
    description = "System paths persisted on /cache";
  };

  den.quirks.cacheHome = {
    description = "User home paths persisted on /cache";
  };

  den.quirks.codium-extensions = {
    description = "Codium/VSCode extensions list or builder function";
  };

  den.quirks.codium-settings = {
    description = "Codium/VSCode user settings declarations";
  };

  den.quirks.firewall = {
    description = "Firewall TCP/UDP port declarations";
  };

  den.quirks.homeManagerModules = {
    description = "Home Manager modules contributed by aspects";
  };

  den.quirks.nixpkgs-overlays = {
    description = "nixpkgs overlays collected from aspects";
  };

  den.quirks.persist = {
    description = "System paths persisted on /persist";
  };

  den.quirks.persistHome = {
    description = "User home paths persisted on /persist";
  };

  den.quirks.secrets = {
    description = "Agenix system secrets declared by aspects";
  };

  den.quirks.secretsHome = {
    description = "Agenix user/home secrets declared by aspects";
  };
}
