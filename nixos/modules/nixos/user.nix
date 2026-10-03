{
  flake.nixosModules.base = { config, ... }: {

    users.users.${config.preferences.user.name} = {
      isNormalUser = true;
      linger = true;
      description = "${config.preferences.user.name}'s account";
      extraGroups = [
        # "root"
        "kvm"
        "libvirtd"
        "networkmanager"
        "render"
        "wheel"
      ];
      initialPassword = "12345";
    };

  };
}
