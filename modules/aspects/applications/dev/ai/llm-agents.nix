# LLM Agents Suite Aspect
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.applications.dev.ai.llm-agents = {
    homeManager =
      { pkgs, ... }:
      let
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {
        home.packages = lib.attrValues (
          lib.filterAttrs (_: v: v != null) {
            inherit (llmPkgs)
              rtk
              ctx
              cli-proxy-api
              terminal-browser
              agent-browser
              # opencodex
              # kimi-code
              # codex
              # agent-deck
              # agentsview
              ;
          }
        );
      };

    nixpkgs-overlays =
      _:
      lib.optionals (inputs ? llm-agents && inputs.llm-agents ? overlays) [
        inputs.llm-agents.overlays.shared-nixpkgs
      ];

    persistHome.directories = [
      ".ctx"
      ".claude"
      ".codex"
      ".kimi-code"
      ".agents"
      ".config/rtk"
      ".local/share/rtk"
    ];
  };
}
