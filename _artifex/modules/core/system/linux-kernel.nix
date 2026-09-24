{
  core.system.linux-kernel = {
    nixos = { pkgs, ... }: {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
