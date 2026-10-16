# LLM Agents Suite Aspect
{
  den,
  inputs,
  lib,
  ...
}:
{
  den.aspects.applications.dev.ai.llm-agents = {
    nixpkgs-overlays =
      _:
      lib.optionals (inputs ? llm-agents && inputs.llm-agents ? overlays) [
        inputs.llm-agents.overlays.shared-nixpkgs
      ];

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
              opencode2
              opencodex
              terminal-browser
              agent-browser
              kimi-code
              codex
              ;
          }
        );
      };
  };
}
