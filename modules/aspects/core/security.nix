# Core Security, PAM, Polkit, GNOME Keyring & Sudo-rs Aspect
{
  den.aspects.core.security = {
    nixos =
      {
        lib,
        pkgs,
        host,
        ...
      }:
      let
        isWorkstation = host.isWorkstation or true;
      in
      {
        environment.systemPackages = lib.optionals isWorkstation (
          with pkgs;
          [
            polkit_gnome
            seahorse
          ]
        );

        security = {
          pam.services = {
            gdm.enableGnomeKeyring = true;
            gdm-password.enableGnomeKeyring = true;
            greetd.enableGnomeKeyring = true;
            login.enableGnomeKeyring = true;
            sddm.enableGnomeKeyring = true;
            sddm-autologin.enableGnomeKeyring = true;
            sddm-greeter.enableGnomeKeyring = true;
          };

          polkit = {
            enable = lib.mkDefault true;
            enablePkexecWrapper = lib.mkDefault true;
          };

          rtkit.enable = lib.mkDefault true;
          sudo.enable = lib.mkForce false;
          sudo-rs.enable = lib.mkDefault true;
        };

        services.gnome.gnome-keyring.enable = lib.mkIf isWorkstation (lib.mkDefault true);

        systemd.user.services.polkit-gnome-authentication-agent-1 = lib.mkIf isWorkstation {
          after = [ "graphical-session.target" ];
          description = "polkit-gnome-authentication-agent-1";

          serviceConfig = {
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
            Type = "simple";
          };

          wantedBy = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];
        };
      };
  };
}
