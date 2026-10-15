# Pi Coding Agent Aspect
{
  den,
  inputs,
  lib,
  ...
}:
{
  den.aspects.applications.dev.ai.pi = {
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
        programs.pi-coding-agent = lib.mkIf (llmPkgs ? pi) {
          enable = true;
          package = llmPkgs.pi;
        };

        home.file = {
          ".pi/agent/settings.json" = {
            source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/pi/agent/settings.json";
            force = true;
          };
          ".pi/agent/extensions/plan-mode" = {
            source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/pi/agent/extensions/plan-mode";
          };
        };
      };

    persistHome.directories = [
      ".pi"
    ];
  };
}
