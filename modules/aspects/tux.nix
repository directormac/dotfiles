{den, ...}: {
  den.aspects.tux = {
    includes = [den.batteries.define-user];
    user.description = "Bird";

    packages = {pkgs, ...}: {
      inherit (pkgs) cowsay;
    };

    tests = {tux, ...}: {
      test-tux-is-bird = {
        expr = tux.description;
        expected = "Bird";
      };
    };
  };
}
