# OpenCode AI Coding Agent Aspect
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.applications.dev.ai.opencode = {
    homeManager =
      { config, pkgs, ... }:
      let
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {

        home.file.".config/opencode/opencode.json" = {
          force = true;
          source = config.lib.dots.link "opencode/opencode.json";
        };

        home.packages = lib.attrValues (
          lib.filterAttrs (_: v: v != null) {
            inherit (llmPkgs)
              opencode2
              ;
          }
        );

        programs.opencode = lib.mkIf (llmPkgs ? opencode) {
          enable = true;
          package = llmPkgs.opencode;
          web.enable = true;
        };

        stylix.targets.opencode.enable = true;
      };

    persistHome.directories = [
      ".opencode"
      ".local/share/opencode"
      ".local/state/opencode"
      ".config/opencode"
      ".config/ai.opencode.desktop"
    ];
  };
}
