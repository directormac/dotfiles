# Virtualization Waydroid Leaf Aspect
{
  den.aspects.virtualization.waydroid = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          waydroid-helper
        ];

        networking.firewall.trustedInterfaces = [
          "waydroid0"
        ];

        virtualisation.waydroid = {
          enable = lib.mkDefault true;

          package = pkgs.waydroid.override {
            withNftables = true;
          };
        };
      };

    homeManager =
      { lib, pkgs, ... }:
      {
        systemd.user.services.waydroid-session = {
          Install = {
            WantedBy = [ ];
          };

          Service = {
            ExecStart = lib.mkDefault "${pkgs.waydroid}/bin/waydroid session start";
            ExecStop = lib.mkDefault "${pkgs.waydroid}/bin/waydroid session stop";
            KillMode = lib.mkDefault "mixed";
            MemoryHigh = "6G";
            MemoryMax = "8G";
            MemoryMin = "256M";
            Restart = lib.mkDefault "on-failure";
            TimeoutStopSec = "15s";
            Type = lib.mkDefault "simple";
          };

          Unit = {
            After = [ "waydroid-container.service" ];
            Description = "Waydroid User Session";
            StopWhenUnneeded = true;
          };
        };
      };
  };
}
