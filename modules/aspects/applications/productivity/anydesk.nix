# AnyDesk Remote Desktop Aspect
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
