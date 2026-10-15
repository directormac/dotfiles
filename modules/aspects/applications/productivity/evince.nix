# Evince Document Viewer Aspect
{ den, ... }:
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
