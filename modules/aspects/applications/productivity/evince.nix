# Evince Document Viewer Aspect
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
