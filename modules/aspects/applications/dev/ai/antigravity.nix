# Antigravity CLI AI Agent Aspect
{
  den,
  inputs,
  lib,
  ...
}:
{
  den.aspects.applications.dev.ai.antigravity = {
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
        llmPkgs =
          pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {
        programs.antigravity-cli = lib.mkIf (llmPkgs ? antigravity-cli) {
          enable = true;
          package = llmPkgs.antigravity-cli;
        };

        home.file.".gemini/antigravity-cli/settings.json" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/antigravity-cli/settings.json";
          force = true;
        };
      };

    persistHome.directories = [
      ".gemini"
    ];
  };
}
