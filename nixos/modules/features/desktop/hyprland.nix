{ self, ... }: {

  flake.homeModules.hyprland =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      # Use stable udev symlink paths for GPU detection
      gpuDevices = lib.concatStringsSep ":" [
        "/dev/dri/pci-0000:03:00.0-card" # AMD (primary for displays)
        "/dev/dri/pci-0000:00:02.0-card" # Intel (secondary)
      ];
    in
    {
      home.file = {
        ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/hypr";
      };

      # Set environment variables for multi-GPU support
      home.sessionVariables = {
        AQ_DRM_DEVICES = gpuDevices;
        WLR_DRM_DEVICES = gpuDevices;
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

  flake.nixosModules.hyprland = { pkgs, config, ... }: {

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
