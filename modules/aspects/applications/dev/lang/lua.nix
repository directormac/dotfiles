# Lua Language Aspect
{ den, ... }:
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
