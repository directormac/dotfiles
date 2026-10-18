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
  };
}
