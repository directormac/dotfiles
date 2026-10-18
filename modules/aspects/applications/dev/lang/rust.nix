# Rust Language Aspect
{
  den.aspects.applications.dev.lang.rust = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          cargo
          rustc
        ];
      };

    cacheHome.directories = [
      ".cargo"
      ".rustup"
    ];
  };
}
