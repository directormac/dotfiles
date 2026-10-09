{ self, ... }: {

  flake.homeModules.hyprland =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      home.file = {
        ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/hypr";
      };

      # services.hyprpolkitagent.enable = true;

      home.packages = with pkgs; [
        hyprlauncher
        hyprland-qt-support
        hyprland-preview-share-picker
      ];

      # wayland.windowManager.hyprland = {
      #   enable = true;
      #   xwayland.enable = true;
      #   configType = "lua";
      # };

    };

  flake.nixosModules.hyprland = { config, ... }: {

    # This is applied to this host with home-manager
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.hyprland
      ];
    };

    # Stable device paths are referenced directly via PCI addresses

    # security.pam.services.hyprlock = { };

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
