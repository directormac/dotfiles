# Service CUPS Printing Aspect
_:
{
  den.aspects.services.printing = {
    nixos =
      { lib, ... }:
      {
        services.printing.enable = lib.mkDefault true;
      };
  };
}
