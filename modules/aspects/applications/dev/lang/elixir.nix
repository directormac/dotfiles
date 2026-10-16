# Elixir & BEAM Language Aspect
_:
{
  den.aspects.applications.dev.lang.elixir = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs.beam29Packages; [
          hex
          elixir_1_20
        ];
      };
  };
}
