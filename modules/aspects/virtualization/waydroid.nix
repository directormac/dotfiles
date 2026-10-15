# Virtualization Waydroid Leaf Aspect
{ den, ... }:
{
  den.aspects.virtualization.waydroid = {
    nixos =
      { lib, pkgs, ... }:
      {
        virtualisation.waydroid = {
          enable = lib.mkDefault true;
          package = pkgs.waydroid.override {
            withNftables = true;
          };
        };

        environment.systemPackages = with pkgs; [
          waydroid-helper
        ];

        networking.firewall.trustedInterfaces = [
          "waydroid0"
        ];
      };

    homeManager =
      { lib, pkgs, ... }:
      {
        systemd.user.services.waydroid-session = {
          Unit = {
            Description = "Waydroid User Session";
            After = [ "waydroid-container.service" ];
            StopWhenUnneeded = true;
          };
          Install = {
            WantedBy = [ ];
          };
          Service = {
            Type = lib.mkDefault "simple";
            ExecStart = lib.mkDefault "${pkgs.waydroid}/bin/waydroid session start";
            ExecStop = lib.mkDefault "${pkgs.waydroid}/bin/waydroid session stop";
            KillMode = lib.mkDefault "mixed";
            MemoryMax = "8G";
            MemoryMin = "256M";
            MemoryHigh = "6G";
            TimeoutStopSec = "15s";
            Restart = lib.mkDefault "on-failure";
          };
        };
      };
  };
}
