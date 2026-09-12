{
  den.ful.security.pam.nixos = {
    security.pam.services.login = {
      enableGnomeKeyring = true;
      /*
      Disabling fingerprint login for TTY means keyring is automatically unlocked
      */
      fprintAuth = false;
    };
  };
}
