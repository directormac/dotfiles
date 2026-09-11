{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.desktop = {
    pkgs,
    config,
    ...
  }: let
    selfpkgs = self.packages."${pkgs.system}";
  in {
    imports = [
      inputs.home-manager.nixosModules.default
      self.nixosModules.gtk
      self.nixosModules.wshowkeys
      self.nixosModules.sddm

      # Wrapped packages
      self.nixosModules.hyprland # This includes dms
      # self.nixosModules.niri # This includes noctalia
      # self.nixosModules.cosmic # Gnome alternative
      self.nixosModules.zen
    ];

    # services.displayManager.defaultSession = "hyprland";

    # preferences.autostart = [selfpkgs.quickshellWrapped];
    # preferences.autostart = [ selfpkgs.noctalia-shell ];

    environment = {
      systemPackages = with pkgs; [
        # Desktop
        quickshell
        kdePackages.qtmultimedia
        cliphist
        wl-clipboard
        # uwsm

        # General apps
        pavucontrol
        nautilus

        # Multimedia
        cava
        mpd
        rmpc
        mpv
        feh
        evince
        galculator
        foliate
        file-roller
        vlc

        # Wrapped
        selfpkgs.which-key
        selfpkgs.kittyfish
        selfpkgs.terminal
      ];

      sessionVariables = {
        EDITOR = "nvim";
        WLR_NO_HARDWARE_CURSORS = "1";
        # Force Electron/Chromium apps to use Wayland
        NIXOS_OZONE_WL = "1";
        # Force Firefox/Zen to use Wayland natively
        MOZ_ENABLE_WAYLAND = "1";
      };

      shellAliases = {
      };
    };

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
      nerd-fonts.symbols-only

      noto-fonts
    ];

    fonts.fontconfig.defaultFonts = {
      serif = ["Noto Serif"];
      sansSerif = ["Noto Sans"];
      monospace = ["Fira Mono Nerd Font"];
    };

    time.timeZone = "Asia/Manila";
    i18n.defaultLocale = "en_PH.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_PH.UTF-8";
      LC_IDENTIFICATION = "en_PH.UTF-8";
      LC_MEASUREMENT = "en_PH.UTF-8";
      LC_MONETARY = "en_PH.UTF-8";
      LC_NAME = "en_PH.UTF-8";
      LC_NUMERIC = "en_PH.UTF-8";
      LC_PAPER = "en_PH.UTF-8";
      LC_TELEPHONE = "en_PH.UTF-8";
      LC_TIME = "en_PH.UTF-8";
    };

    # Enable networking
    networking.networkmanager.enable = true;

    services.upower.enable = true;

    security.polkit.enable = true;

    programs.firefox.enable = true;

    home-manager.users.${config.preferences.user.name} = {
      config,
      lib,
      ...
    }: let
      # Define where your flake lives on the live filesystem
      flakePath = "${config.home.homeDirectory}/.dotfiles";

      linkDank = name: type:
        if name == "plugins"
        then {}
        else {
          ".config/DankMaterialShell/${name}".source =
            config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/DankMaterialShell/${name}";
        };
    in {
      wayland.windowManager.hyprland.systemd.enable = false;

      # Dotfiles here for desktop related apps
      home.file =
        {
          ".face".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/.face";
          ".config/wallpapers".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/wallpapers";

          # Apps
          ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/ghostty";
          ".config/kitty/kitty.conf".source =
            config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/kitty/kitty.conf";

          # --- Wayland things ---
          ".config/noctalia".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/noctalia";
          ".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/niri";
          ".config/cosmic".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/cosmic";
          ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/hypr";
        }
        # This merges the filtered directory directly into your home.file
        // lib.concatMapAttrs linkDank (builtins.readDir ../../config/DankMaterialShell);
    };

    # hardware = {
    #   enableAllFirmware = true;
    #
    #   bluetooth.enable = true;
    #   bluetooth.powerOnBoot = true;
    #
    #   opengl = {
    #     enable = true;
    #     driSupport32Bit = true;
    #   };
    # };
  };
}
