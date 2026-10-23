# Core Networking, Firewall & NetworkManager Aspect
{ lib, ... }:
let
  hasWifiSecret = builtins.pathExists wifiSecretAgeFile;
  repoRoot = ../../..;
  wifiSecretAgeFile = repoRoot + "/.secrets/wifi.env.age";
in
{
  den.aspects.core.networking = {
    nixos =
      {
        config,
        lib,
        pkgs,
        host,
        ...
      }:
      let
        hasWifiSecretConfig = (config ? age) && (config.age.secrets ? wifi-env);
      in
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

          networkmanager = {
            enable = lib.mkDefault true;

            ensureProfiles = {
              environmentFiles = lib.optional hasWifiSecretConfig config.age.secrets.wifi-env.path;

              profiles = {
                "Wired" = {
                  connection = {
                    autoconnect = true;
                    id = "Wired";
                    type = "ethernet";
                  };

                  ipv4 = {
                    address1 = "192.168.66.251/24";
                    dns = "192.168.66.1;1.1.1.1;8.8.8.8;";
                    gateway = "192.168.66.1";
                    method = "manual";
                    route-metric = 100;
                  };

                  ipv6 = {
                    addr-gen-mode = "stable-privacy";
                    method = "auto";
                  };
                };
              }
              // lib.optionalAttrs hasWifiSecretConfig {
                "MKRA" = {
                  connection = {
                    autoconnect = true;
                    id = "MKRA";
                    type = "wifi";
                  };

                  ipv4 = {
                    address1 = "192.168.66.251/24";
                    dns = "192.168.66.1;1.1.1.1;";
                    gateway = "192.168.66.1";
                    method = "manual";
                    route-metric = 600;
                  };

                  ipv6 = {
                    addr-gen-mode = "stable-privacy";
                    method = "auto";
                  };

                  wifi = {
                    mode = "infrastructure";
                    ssid = "MKRA";
                  };

                  wifi-security = {
                    auth-alg = "open";
                    key-mgmt = "wpa-psk";
                    psk = "$WIFI_PASSWORD_MKRA";
                  };
                };

                "PAGE" = {
                  connection = {
                    autoconnect = true;
                    id = "PAGE";
                    type = "wifi";
                  };

                  ipv4 = {
                    address1 = "192.168.123.251/24";
                    dns = "192.168.123.1;1.1.1.1;";
                    gateway = "192.168.123.1";
                    method = "manual";
                    route-metric = 600;
                  };

                  ipv6 = {
                    addr-gen-mode = "stable-privacy";
                    method = "auto";
                  };

                  wifi = {
                    mode = "infrastructure";
                    ssid = "PAGE";
                  };

                  wifi-security = {
                    auth-alg = "open";
                    key-mgmt = "wpa-psk";
                    psk = "$WIFI_PASSWORD_PAGE";
                  };
                };
              };
            };
          };
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

    secrets = lib.optionalAttrs hasWifiSecret {
      wifi-env = {
        mode = "0400";
        rekeyFile = wifiSecretAgeFile;
      };
    };
  };
}
