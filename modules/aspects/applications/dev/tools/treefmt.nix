{
  den.aspects.applications.dev.tools.treefmt = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.treefmt
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.treefmt
        ];
      };

    tests = {
      testExampleMath = {
        expected = 2;
        expr = 1 + 1;
      };

      testExampleString = {
        expected = "hello world";
        expr = "hello " + "world";
      };
    };
  };
}
