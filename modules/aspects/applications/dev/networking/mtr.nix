# MTR Network Diagnostic Aspect
{ den, ... }:
{
  den.aspects.applications.dev.networking.mtr = {
    nixos = {
      programs.mtr.enable = true;
    };
  };
}
