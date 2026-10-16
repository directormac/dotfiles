# Lua Language Aspect
{
  den.aspects.applications.dev.lang.lua = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          lua5_1
          luarocks-nix
          lua-language-server
          stylua
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          lua5_1
          luarocks-nix
          lua-language-server
          stylua
        ];
      };
  };

  flake.wrappers.neovim =
    { pkgs, ... }:
    {
      config.specs.lua = {
        after = [ "general" ];

        data = with pkgs.vimPlugins; [
          lazydev-nvim
        ];

        lazy = true;

        runtimePkgs = with pkgs; [
          lua-language-server
          stylua
        ];
      };
    };
}
