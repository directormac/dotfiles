# Lua Language Aspect
_:
{
  den.aspects.applications.dev.lang.lua = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          luarocks-nix
        ];
      };
  };
}
