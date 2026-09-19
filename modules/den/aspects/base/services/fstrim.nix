{
  den.aspects.base.services.fstrim = {
    nixos = {
      services.fstrim = {
        enable = true;
        interval = "weekly";
      };
    };
  };
}
