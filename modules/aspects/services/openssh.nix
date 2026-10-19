# Service OpenSSH Daemon Aspect
{ den, ... }:
{
  den.aspects.services.openssh = {
    nixos =
      {
        lib,
        host,
        ...
      }:
      {
        services.openssh = {
          enable = lib.mkDefault true;

          settings = {
            KbdInteractiveAuthentication = lib.mkDefault true;
            PasswordAuthentication = lib.mkDefault true;
            PermitRootLogin = lib.mkOptionDefault "prohibit-password";
            UseDns = lib.mkDefault true;
            X11Forwarding = lib.mkDefault false;
          };

          hostKeys = lib.mkIf (host.hasAspect den.aspects.impermanence) [
            {
              path = "/persist/etc/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
            {
              bits = 4096;
              path = "/persist/etc/ssh/ssh_host_rsa_key";
              type = "rsa";
            }
          ];

          ports = lib.mkDefault [ 22 ];
        };
      };
  };
}
