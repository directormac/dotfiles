# LLM Agents Suite Aspect
# https://github.com/numtide/llm-agents.nix
# https://numtide.github.io/llm-agents.nix/
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
              skills
              # collie (managed by dev.mux.herdr / dev.mux.tmux)
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
      ".local/state/ctx"
      ".claude"
      ".codex"
      ".kimi-code"
      ".agents"
      ".cline"
      ".config/rtk"
      ".local/share/rtk"
    ];
  };
}
