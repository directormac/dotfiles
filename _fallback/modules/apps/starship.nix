{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages = {
      starship = inputs.wrappers.lib.wrapPackage (_: {
        inherit pkgs;
        package = pkgs.starship;

        env = {
          STARSHIP_CONFIG = toString ../../../config/starship/starship.toml;
        };
      });
    };

  };
}
