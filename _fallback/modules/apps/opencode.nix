{ self, ... }: {

  flake.homeModules.opencode = {

    programs.antigravity-cli = {
      enable = true;

      # Configuration
      settings = {
        defaultMode = "plan";

        # Optional: You can also lock down the tool review policies for plan mode safety
        permissions = {
          toolExecution = "request-review";
        };
      };
    };

    programs.opencode = {
      enable = true;
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

    # programs.opencode = {
    #   enable = true;
    # };

  };

  flake.nixosModules.opencode = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        opencode
      ];
    };

    environment.systemPackages = with pkgs; [
      opencode
      opencode-desktop
    ];
  };
}
