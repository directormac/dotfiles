# Foliate E-Book Reader Aspect
{
  den.aspects.applications.productivity.foliate = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.foliate
        ];

        stylix.targets.foliate.enable = true;
      };
  };
}
