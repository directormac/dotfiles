# Evince Document Viewer Aspect
_:
{
  den.aspects.applications.productivity.evince = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.evince
        ];
      };
  };
}
