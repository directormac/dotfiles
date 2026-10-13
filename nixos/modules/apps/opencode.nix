{
  inputs,
  self,
  ...
}:
{

  flake.homeModules.opencode =
    {
      pkgs,
      config,
      ...
    }:
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

  flake.nixosModules.opencode = { config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        opencode
      ];
    };

    nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];

  };
}
