{
  den.aspects.base.security = {
    nixos = {pkgs, ...}: {
      security.polkit.enable = true;

      environment.systemPackages = [
        # pkgs.clevis
        # pkgs.jose
      ];
    };

    persist = {
    };
  };
}
