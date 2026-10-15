# Service CUPS Printing Aspect
{ den, ... }:
{
  den.aspects.services.printing = {
    nixos =
      { lib, ... }:
      {
        services.printing.enable = lib.mkDefault true;
      };
  };
}
