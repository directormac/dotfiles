{
  core.set-user = { user, ... }: {
    nixos = {
      users.groups.input.members = [ user.userName ];
      users.groups.uinput.members = [ user.userName ];

      users.users = {
        ${user.userName} = {
          # inherit (user.userName) description;
          extraGroups = [
            # "networkmanager"
            "wheel"
            "video"
            "audio"
            "camera"
            "kvm"
            "libvirtd"
            "lp"
            "scanner"
            "docker"
          ];

          # You can set an initial password for your user.
          # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
          # Be sure to change it (using passwd) after rebooting!
          initialPassword = "12345";
          isNormalUser = true;

          openssh.authorizedKeys.keys = [
          ];
        };
      };
    };
  };
}
