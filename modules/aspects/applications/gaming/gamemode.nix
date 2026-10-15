# GameMode Performance Optimizer Aspect
{ den, ... }:
{
  den.aspects.applications.gaming.gamemode = {
    nixos = {
      programs.gamemode.enable = true;
    };
  };
}
