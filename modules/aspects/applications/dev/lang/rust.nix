# Rust Language Aspect
{ den, ... }:
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
