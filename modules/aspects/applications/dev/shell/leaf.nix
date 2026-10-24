# Leaf - https://github.com/rivolink/leaf
{
  den.aspects.applications.dev.shell.leaf = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (pkgs.local.leaf or pkgs.leaf)
        ];
      };

    # config.toml, themes/ and history.toml are user-edited state
    persistHome.directories = [ ".config/leaf" ];
  };
}
