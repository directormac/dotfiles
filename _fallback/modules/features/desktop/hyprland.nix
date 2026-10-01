{ self, ... }: {

  flake.homeModules.hyprland =
    { pkgs, config, ... }:
    {
      home.file = {
        ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/hypr";
      };

      services.hyprpolkitagent.enable = true;

      home.packages = with pkgs; [
        hyprlauncher
        hyprland-qt-support
      ];

      # wayland.windowManager.hyprland = {
      #   enable = true;
      #   xwayland.enable = true;
      #   configType = "lua";
      # };

    };

  flake.nixosModules.hyprland = { pkgs, config, ... }: {

    # This is applied to this host with home-manager
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.hyprland
      ];
    };

    programs.uwsm = {
      enable = true;
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

  };
}
