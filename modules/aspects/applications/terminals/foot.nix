# Foot Terminal Emulator Leaf Aspect
{ den, ... }:
{
  den.aspects.applications.terminals.foot = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.foot
        ];
      };
  };
}
