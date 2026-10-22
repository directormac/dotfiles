# GitHub Copilot CLI & Language Server Aspect
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.applications.dev.ai.copilot = {
    homeManager =
      { pkgs, ... }:
      let
        copilot-cli =
          if llmPkgs ? copilot-cli && llmPkgs.copilot-cli != null then
            llmPkgs.copilot-cli.overrideAttrs (old: {
              # Node SEA binary in 1.0.102+ segfaults if patchelf modifies RPATH
              # (grows .dynamic and corrupts the embedded SEA blob); makeWrapper
              # already provides LD_LIBRARY_PATH.
              installPhase = builtins.replaceStrings [ "--set-rpath \"${libPath}\"" ] [ "" ] (
                old.installPhase or ""
              );
            })
          else
            null;
        libPath = lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ];
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {
        home.packages =
          lib.attrValues (
            lib.filterAttrs (_: v: v != null) {
              inherit copilot-cli;

              inherit (llmPkgs)
                copilot-language-server
                ;
            }
          )
          ++ [
            pkgs.github-mcp-server
          ];
      };

    persistHome.directories = [
      ".copilot"
      ".config/github-copilot"
      ".local/share/github-copilot"
    ];
  };
}
