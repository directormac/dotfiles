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

      home.file.".gemini/antigravity-cli/settings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/antigravity-cli/settings.json";
        force = true;
      };

      # home.file.".gemini/antigravity-cli/settings.json" = {
      #   text =
      #     # json
      #     ''
      #       {
      #         "defaultMode" : "plan",
      #         "altScreenMode": "always",
      #         "notifications":true,
      #         "enableTerminalSandbox": true,
      #         "toolPermission" : "request-review";
      #         "trustedWorkspaces": [
      #           "${config.home.homeDirectory}/.dotfiles"
      #           "${config.home.homeDirectory}/Projects"
      #         ],
      #         "permissions" :{
      #           "allow": [
      #             "command(git)",
      #           ]
      #         }
      #
      #       }
      #     '';
      #   force = true;
      # };

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

      home.packages = [
        pkgs.llm-agents.omo-ai
        pkgs.opencode-desktop
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
