# Pi Coding Agent Aspect
{
  lib,
  inputs,
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
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {

        home.file = {
          ".pi/agent/extensions/plan-mode" = {
            source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/pi/agent/extensions/plan-mode";
          };

          ".pi/agent/settings.json" = {
            force = true;
            source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/pi/agent/settings.json";
          };
        };

        home.packages = [
          pkgs.fff-mcp
        ]
        ++ (lib.attrValues (
          lib.filterAttrs (_: v: v != null) {
            inherit (llmPkgs)
              omo-ai
              omp
              ;
          }
        ));

        programs.pi-coding-agent = lib.mkIf (llmPkgs ? pi) {
          enable = true;
          package = llmPkgs.pi;
        };
      };

    persistHome.directories = [
      ".pi"
      ".omo"
      ".omp"
    ];
  };
}
