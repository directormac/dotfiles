# Antigravity CLI AI Agent Aspect
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.applications.dev.ai.antigravity = {
    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {
        home.file.".gemini/antigravity-cli/settings.json" = {
          force = true;
          source = config.lib.dots.link "antigravity-cli/settings.json";
        };

        programs.antigravity-cli = lib.mkIf (llmPkgs ? antigravity-cli) {
          enable = true;
          package = llmPkgs.antigravity-cli;
        };
      };

    persistHome.directories = [
      ".gemini"
    ];
  };
}
