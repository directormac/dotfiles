{den, ...}: {
  den.aspects.roles.default = {
    includes = with den.aspects; [
      base.nix
      base.nix.nixpkgs
      base.systemd.boot
      base.localization.i18n
      base.nix.stateVersion
      base.systemd
      base.users.shell
      base.core
      base.system.firmware
      base.security
      # base.system.facter
      base.users.home-manager-shared
      base.users.deterministic-uids
      # #core.nix.remote-build-client
      # core.security.sudo
      base.localization.time
      base.services.fstrim
      base.nix.disable-docs
      base.system.linux-kernel
      base.users

      base.impermanence

      applications.shell.zsh

      # core.network.networking
      base.security.openssh
      # core.security.opkssh
      # core.network.hostsfile
      # core.network.tailscale
      # core.network.syncthing.member

      secrets.agenix
    ];
  };
}
