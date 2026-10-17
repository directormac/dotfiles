# Looking Glass KVM Frame Relay Client Aspect
_: {
  den.aspects.virtualization.looking-glass = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        boot.extraModprobeConfig = lib.mkDefault ''
          options kvmfr static_size_mb=128
        '';

        boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
        boot.kernelModules = [ "kvmfr" ];

        environment.systemPackages = [
          (pkgs.local.looking-glass-client or pkgs.looking-glass-client)
        ];

        services.udev.extraRules = ''
          SUBSYSTEM=="kvmfr", OWNER="root", GROUP="kvm", MODE="0660"
        '';

        systemd.tmpfiles.rules = [
          "f /dev/shm/looking-glass 0660 root kvm -"
        ];
      };

    homeManager = _: {
      xdg.configFile."looking-glass/client.ini".text = ''
        [app]
        shmFile=/dev/kvmfr0

        [win]
        fullScreen=no
        showFPS=yes

        [input]
        escapeKey=KEY_RIGHTCTRL
        autoCapture=yes

        [spice]
        enable=yes
      '';
    };
  };
}
