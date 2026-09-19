{
  den.aspects.base.core = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = [
        # pkgs.git
        # pkgs.devenv
        # pkgs.direnv
        # pkgs.manix

        pkgs.btop
        pkgs.coreutils
        pkgs.curl
        pkgs.fd
        pkgs.file
        pkgs.findutils
        pkgs.unzip
        pkgs.wget
        pkgs.netcat
        pkgs.tcpdump

        pkgs.lm_sensors
        pkgs.lsof
        pkgs.killall
        pkgs.pciutils
        pkgs.usbutils
        pkgs.psmisc
        pkgs.traceroute
        pkgs.vim
      ];
      # ++ lib.optional config.hardware.nvidia.modesetting.enable pkgs.btop-cuda;

      # Log diff when system update is applied
      system.activationScripts.diff = {
        supportsDryActivation = true;
        text = ''
          if [[ -e /run/current-system ]]; then
            ${lib.getExe pkgs.nvd} --color=always --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig" || echo "FAILED TO GENERATE DIFF"
          fi
        '';
      };
    };
  };
}
