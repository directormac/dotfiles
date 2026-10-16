# Rust Language Aspect
_:
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
  };
}
