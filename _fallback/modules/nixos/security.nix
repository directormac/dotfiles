{ inputs, ... }: {
  flake.nixosModules.base = { pkgs, ... }: {

    security = {
      rtkit.enable = true;
      polkit.enable = true;
      pam.services = {
        gdm.enableGnomeKeyring = true;
        gdm-password.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };
      sudo.extraConfig = "Defaults pwfeedback";

      # wrappers.pkexec = {
      #   owner = "root";
      #   group = "root";
      #   setuid = true;
      #   source = "${pkgs.polkit.bin}/bin/pkexec";
      # };

      # apparmor = {
      #   enable = true;
      #   killUnconfinedConfinables = true;
      #   packages = [ pkgs.apparmor-profiles ];
      # };

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
