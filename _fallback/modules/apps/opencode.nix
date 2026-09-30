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

      home.file.".gemini/antigravity-cli/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/antigravity-cli/settings.json";

      # home.file.".gemini/antigravity-cli/settings.json" =
      #   # json
      #   ''
      #     {
      #       "defaultMode" : "plan",
      #       "altScreenMode": "always",
      #       "notifications":true,
      #       "enableTerminalSandbox": true,
      #       "toolPermission" : "request-review";
      #       "trustedWorkspaces": [
      #         "${config.home.homeDirectory}/.dotfiles"
      #         "${config.home.homeDirectory}/Projects"
      #       ],
      #       "permissions" :{
      #         "allow": [
      #           "command(git)",
      #         ]
      #       }
      #
      #     }
      #   '';

      programs.antigravity-cli = {
        enable = true;
        package = pkgs.llm-agents.antigravity-cli;

        # Configuration written directly to ~/.gemini/antigravity-cli/settings.json
        # settings = {
        #   "agentMode" = "plan"; # Sets the default launch to Planning Mode
        #   "altScreenMode" = "always";
        #   "notifications" = true;
        #   "enableTerminalSandbox" = true; # Keeps the secure bubblewrap runtime active
        #   "toolPermission" = "request-review";
        #
        #   "trustedWorkspaces" = [
        #     "${config.home.homeDirectory}/.dotfiles"
        #     "${config.home.homeDirectory}/Projects"
        #   ];
        #
        #   "permissions" = {
        #     "allow" = [
        #       "command(git)"
        #       "command(curl)"
        #       "command(ls)"
        #       "command(cat)"
        #       "read_file(/nix/store/*)" # Globally wildcards file readability across the Nix store
        #     ];
        #   };
        # };
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

  flake.nixosModules.opencode = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        opencode
      ];
    };

    nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];

  };
}
