{ den, ... }:
{
  den.aspects.base.impermanence.tmpfs = {
    nixos = {
      boot.tmp = {
        useTmpfs = true;
        cleanOnBoot = true;
      };
    };
  };
}
