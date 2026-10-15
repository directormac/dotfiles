# OpenCode AI Coding Agent Aspect
{
  den,
  inputs,
  lib,
  ...
}:
{
  den.aspects.applications.dev.ai.opencode = {
    homeManager =
      { pkgs, ... }:
      let
        llmPkgs =
          pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {
        stylix.targets.opencode.enable = true;

        programs.opencode = lib.mkIf (llmPkgs ? opencode) {
          enable = true;
          package = llmPkgs.opencode;
          settings = {
            autoshare = false;
            autoupdate = true;
            permission = {
              external_directory = {
                "/nix/store/**" = "allow";
                "/tmp/**" = "allow";
              };
              read = {
                "$HOME/.dotfiles" = "allow";
                "$HOME/.config" = "allow";
                "/nix/store/**" = "allow";
                "*.env" = "deny";
              };
              edit = {
                "/nix/store/**" = "deny";
              };
            };
          };
        };
      };

    persistHome.directories = [
      ".local/share/opencode"
    ];
  };
}
