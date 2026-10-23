# Service Tailscale VPN Aspect
{ lib, ... }:
let
  authKeyAgeFile = repoRoot + "/.secrets/tailscale-auth-key.age";
  hasAuthKey = builtins.pathExists authKeyAgeFile;
  repoRoot = ../../..;
in
{
  den.aspects.services.tailscale = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        hasAuthKeySecret = (config ? age) && (config.age.secrets ? "tailscale-auth-key");
        operatorName = if primaryUser != null then primaryUser.name else "artifex";
        primaryUser = lib.findFirst (u: u.isNormalUser) null (builtins.attrValues config.users.users);
      in
      {
        environment.systemPackages = [ pkgs.tailscale ];
        networking.firewall.trustedInterfaces = [ "tailscale0" ];

        services.tailscale = {
          enable = lib.mkDefault true;
          authKeyFile = lib.mkIf hasAuthKeySecret config.age.secrets."tailscale-auth-key".path;

          extraUpFlags = [
            "--operator=${operatorName}"
          ];

          openFirewall = lib.mkDefault true;
          useRoutingFeatures = lib.mkDefault "client";
        };
      };

    persist.directories = [
      "/var/lib/tailscale"
    ];

    secrets = lib.optionalAttrs hasAuthKey {
      tailscale-auth-key = {
        mode = "0400";
        rekeyFile = authKeyAgeFile;
      };
    };
  };
}
