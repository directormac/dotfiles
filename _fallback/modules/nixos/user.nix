{
  flake.nixosModules.base = { config, ... }: {

    users.users.${config.preferences.user.name} = {
      isNormalUser = true;
      linger = true;
      description = "${config.preferences.user.name}'s account";
      extraGroups = [
        "adbusers"
        "audio"
        "disk"
        "docker"
        "input"
        "kvm"
        "libvirt"
        "libvirt-qemu"
        "libvirtd"
        "lp"
        "networkmanager"
        "podman"
        "render"
        "root"
        "scanner"
        "vboxusers"
        "video"
        "waydroid"
        "wheel"
      ];
      initialPassword = "12345";
    };

  };
}
