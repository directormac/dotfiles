{
  inputs,
  self,
  ...
}:
{

  flake.homeModules.ai =
    {
      pkgs,
      config,
      ...
    }:
    let
      pi-config-path = ".pi/agent";
      pi-config-source-path = "${config.preferences.dotsConfigPath}/pi/agent";
    in
    {

      stylix.targets = {
        opencode.enable = true;
      };

      home.file.".gemini/antigravity-cli/settings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/antigravity-cli/settings.json";
        force = true;
      };

      programs.antigravity-cli = {
        enable = true;
        package = pkgs.llm-agents.antigravity-cli;
      };

      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
        settings = {
          autoshare = false;
          autoupdate = true;
          permission = {
            external_directory = {
              # Allows OpenCode to access and read the Nix store
              "/nix/store/**" = "allow";
              "/tmp/**" = "allow";
            };

            # Optional: Explicitly guarantee read access, while blocking write/edit access
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

      programs.pi-coding-agent = {
        enable = true;
        package = pkgs.llm-agents.pi;
      };

      home.file = {
        "${pi-config-path}/settings.json" = {
          source = config.lib.file.mkOutOfStoreSymlink "${pi-config-source-path}/settings.json";
          force = true;
        };
        "${pi-config-path}/extensions/plan-mode" = {
          source = config.lib.file.mkOutOfStoreSymlink "${pi-config-source-path}/extensions/plan-mode";
        };
      };

      home.packages = with pkgs.llm-agents; [
        rtk # https://www.rtk-ai.app/docs/
        ctx # https://ctx.rs/
        cli-proxy-api # https://help.router-for.me/configuration/basic.html

        copilot-cli
        copilot-language-server

        omo-ai
        opencode2
        opencodex
        terminal-browser
        agent-browser
        kimi-code
        code # https://github.com/just-every/code/
        codex
      ];

    };

  flake.nixosModules.ai = { config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        ai
      ];
    };

    nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];

  };
}
