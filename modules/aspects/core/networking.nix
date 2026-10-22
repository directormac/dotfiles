# Core Networking, Firewall & NetworkManager Aspect
{
  den.aspects.core.networking = {
    nixos =
      {
        lib,
        pkgs,
        host,
        ...
      }:
      {
        environment.systemPackages = lib.optionals (host.isWorkstation or true) [
          pkgs.networkmanagerapplet
        ];

        networking = {
          firewall = {
            allowedTCPPortRanges = [
              {
                from = 1714;
                to = 1764;
              }
            ];

            allowedTCPPorts = [
              22
              80
              443
              445
              59010
              59011
              8080
            ];

            allowedUDPPortRanges = [
              {
                from = 1714;
                to = 1764;
              }
            ];

            allowedUDPPorts = [
              137
              138
              59010
              59011
            ];

            enable = lib.mkDefault true;
          };

          hosts = {
            "192.168.66.100" = [ "fileserver" ];
          };

          nameservers = [
            "1.1.1.1"
            "8.8.8.8"
          ];

          networkmanager.enable = lib.mkDefault true;
        };

        programs.ssh.extraConfig = ''
          Host github.com
            Hostname ssh.github.com
            Port 443
            User git
        '';

        services.resolved = {
          enable = lib.mkDefault true;
        };
      };

    persist.directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/NetworkManager"
    ];
  };
}
