# Node.js, TypeScript, Web Tools & Runtimes Aspect
{
  lib,
  inputs,
  ...
}:
let
  webPkgs =
    pkgs: with pkgs; [
      nodejs_26
      bun
      deno
      typescript
      oxfmt
      oxlint
      tailwindcss-language-server
      svelte-language-server
      astro-language-server
      emmet-language-server
    ];
in
{
  flake-file.inputs = {
    nix-vite-plus.url = "github:ryoppippi/nix-vite-plus";
  };

  den.aspects.applications.dev.lang.node = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = webPkgs pkgs;
      };

    homeManager =
      { pkgs, ... }:
      let
        viteplus =
          if inputs ? nix-vite-plus then
            inputs.nix-vite-plus.packages.${pkgs.stdenv.hostPlatform.system}.vp
          else
            null;
      in
      {
        home.packages = (webPkgs pkgs) ++ lib.optional (viteplus != null) viteplus;
        home.sessionPath = [
          "$HOME/.local/share/vite-plus/bin"
        ];
      };

    persistHome.directories = [
      ".config/vite-plus"
      ".local/share/vite-plus"
      ".bun"
      ".npm"
    ];
  };

  flake.wrappers.neovim =
    { pkgs, ... }:
    {
      config.specs.web = {
        data = null;

        runtimePkgs = with pkgs; [
          emmet-language-server
          typescript
          oxfmt
          oxlint
          tailwindcss-language-server
          svelte-language-server
          astro-language-server
        ];
      };
    };
}
