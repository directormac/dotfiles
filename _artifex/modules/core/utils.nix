{
  core.utils = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
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
    };
  };
}
