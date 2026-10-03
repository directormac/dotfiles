{ inputs, ... }: {
  flake.nixosModules.base = { pkgs, ... }: {

    security = {
      rtkit.enable = true;
      polkit = {
        enable = true;
        enablePkexecWrapper = true;
      };
      pam.services = {
        gdm.enableGnomeKeyring = true;
        gdm-password.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };
      sudo.extraConfig = "Defaults pwfeedback";

      # apparmor = {
      #   enable = true;
      #   killUnconfinedConfinables = true;
      #   packages = [ pkgs.apparmor-profiles ];
      # };

    };

    environment.systemPackages = [ pkgs.polkit_gnome ];

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # zramSwap = {
    #   enable = true;
    #   memoryPercent = 50;
    #   algorithm = "zstd";
    # };
    #
    # systemd.oomd = {
    #   enable = true;
    #   enableUserSlices = true;
    # };
    #
    # systemd.slices."user".sliceConfig = {
    #   ManagedOOMMemoryPressure = "kill";
    #   ManagedOOMMemoryPressureLimit = "90%";
    # };

  };
}
