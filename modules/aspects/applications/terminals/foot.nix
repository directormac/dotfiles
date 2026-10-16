# Foot Terminal Emulator Leaf Aspect
_:
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
