# Service OpenSSH Daemon Aspect
{
  den.aspects.services.openssh = {
    nixos =
      { lib, ... }:
      {
        services.openssh = {
          settings = {
            KbdInteractiveAuthentication = lib.mkDefault true;
            PasswordAuthentication = lib.mkDefault true;
            PermitRootLogin = lib.mkOptionDefault "prohibit-password";
            UseDns = lib.mkDefault true;
            X11Forwarding = lib.mkDefault false;
          };

          enable = lib.mkDefault true;
          ports = lib.mkDefault [ 22 ];
        };
      };

    persist.files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
