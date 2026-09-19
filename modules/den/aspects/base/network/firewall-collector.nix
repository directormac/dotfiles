{
  den.aspects.base.network.firewall-collector = {
    nixos = {
      firewall ? [],
      lib,
      ...
    }:
      lib.mkMerge firewall;
  };
}
