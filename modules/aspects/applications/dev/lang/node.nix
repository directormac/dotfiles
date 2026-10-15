# Node.js, Bun, Deno & VitePlus Language Aspect
{
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    nix-vite-plus.url = "github:ryoppippi/nix-vite-plus";
  };

  den.aspects.applications.dev.lang.node = {
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
        home.packages =
          (with pkgs; [
            nodejs_26
            bun
            deno
          ])
          ++ lib.optional (viteplus != null) viteplus;
      };
  };
}
