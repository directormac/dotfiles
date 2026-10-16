# AnyDesk Remote Desktop Aspect
_:
{
  den.aspects.applications.productivity.anydesk = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.anydesk
        ];
      };
  };
}
