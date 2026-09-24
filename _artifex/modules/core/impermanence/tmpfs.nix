{
  core.impermanence.tmpfs = {
    nixos = {
      boot.tmp = {
        cleanOnBoot = true;
        useTmpfs = true;
      };
    };
  };
}
