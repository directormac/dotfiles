{
  flake.nixosModules.base = { config, ... }: {

    users.users.${config.preferences.user.name} = {
      isNormalUser = true;
      description = "${config.preferences.user.name}'s account";
      extraGroups = [
        "kvm"
        "libvirt"
        "libvirt-qemu"
        "networkmanager"
        "root"
        "wheel"
      ];
      initialPassword = "12345";
    };

  };
}
