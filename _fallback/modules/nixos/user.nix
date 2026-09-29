{
  flake.nixosModules.base = { config, ... }: {

    users.users.${config.preferences.user.name} = {
      isNormalUser = true;
      linger = true;
      description = "${config.preferences.user.name}'s account";
      extraGroups = [
        "kvm"
        "libvirt"
        "libvirt-qemu"
        "networkmanager"
        "root"
        "wheel"
        "podman"
        "docker"
      ];
      initialPassword = "12345";
    };

  };
}
