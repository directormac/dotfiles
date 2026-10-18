# OpenCode AI Coding Agent Aspect
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.applications.dev.ai.opencode = {
    homeManager =
      { pkgs, ... }:
      let
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {

        home.packages = lib.attrValues (
          lib.filterAttrs (_: v: v != null) {
            inherit (llmPkgs)
              opencode2
              ;
          }
        );

        programs.opencode = lib.mkIf (llmPkgs ? opencode) {
          settings = {
            autoshare = false;
            autoupdate = false;

            permission = {
              edit = {
                "/nix/store/**" = "deny";
              };

              external_directory = {
                "/nix/store/**" = "allow";
                "/tmp/**" = "allow";
              };

              read = {
                "$HOME/.config" = "allow";
                "$HOME/.dotfiles" = "allow";
                "*.env" = "deny";
                "/nix/store/**" = "allow";
              };
            };

            # plugins is a top-level property, not inside permission
            plugins = [
              # https://github.com/darrenhinde/OpenAgentsControl
              "opencode-goal-plugin@0.11.0"
              "opencode-conductor"
              "micode"
              "openportal"
              "oh-my-opencode"
              "opencode-supermemory"
              "opencode-pty"
              "opencode-websearch-cited"
            ];
          };

          enable = true;
          package = llmPkgs.opencode;
          web.enable = true;
        };

        stylix.targets.opencode.enable = true;
      };

    persistHome.directories = [
      ".local/share/opencode"
      ".local/state/opencode"
      ".config/opencode"
      ".config/ai.opencode.desktop"
    ];
  };
}
