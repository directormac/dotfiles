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
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {
        home.packages =
          lib.attrValues (
            lib.filterAttrs (_: v: v != null) {
              inherit (llmPkgs)
                copilot-cli
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
      "~/.local/share/github-copilot/"
    ];
  };
}
