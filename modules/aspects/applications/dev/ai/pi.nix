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
        ...
      }:
      let
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {

        home.file = {
          ".omp/agent/config.yml" = {
            force = true;
            source = config.lib.dots.link "omp/agent/config.yml";
          };

          ".pi/agent/extensions/plan-mode" = {
            source = config.lib.dots.link "pi/agent/extensions/plan-mode";
          };

          ".pi/agent/settings.json" = {
            force = true;
            source = config.lib.dots.link "pi/agent/settings.json";
          };
        };

        home.packages = [
          pkgs.fff-mcp
        ]
        ++ (lib.attrValues (
          lib.filterAttrs (_: v: v != null) {
            inherit (llmPkgs)
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
      ".omp"
      ".config/pi"
    ];
  };
}
