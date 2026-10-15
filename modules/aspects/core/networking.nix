# Core Networking, Firewall & NetworkManager Aspect
{ den, ... }:
{
  den.aspects.core.networking = {
    nixos =
      {
        host,
        lib,
        pkgs,
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

          networkmanager.enable = lib.mkDefault true;
        };

        programs.ssh.extraConfig = ''
          Host github.com
            Hostname ssh.github.com
            Port 443
            User git
        '';
      };

    persist.directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
