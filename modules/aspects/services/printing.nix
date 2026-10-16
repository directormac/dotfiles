# Service CUPS Printing Aspect
{
  den.aspects.services.printing = {
    nixos =
      { lib, ... }:
      {
        services.printing.enable = lib.mkDefault true;
      };
  };
}
