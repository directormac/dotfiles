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
        programs.opencode = lib.mkIf (llmPkgs ? opencode) {
          settings = {
            autoshare = false;
            autoupdate = true;

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
          };

          enable = true;
          package = llmPkgs.opencode;
        };

        stylix.targets.opencode.enable = true;
      };

    persistHome.directories = [
      ".local/share/opencode"
    ];
  };
}
