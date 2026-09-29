{ self, ... }: {
  flake.homeModules.desktop-services = { pkgs, ... }: {

    # services.tailscale-systray = {
    #   enable = true;
    # };

    services.udiskie = {
      enable = true;
      settings = {
        icon_names = {
          media = [
            "drive-removable-media-usb"
            "drive-removable-media"
            "media-flash"
            "media-optical"
          ];
        };
        program_options = {
          tray = true;
          udisks_version = 2;
          # file_manager = "${pkgs.nautilus}/bin/nautilus";
        };

      };
    };

    services.mpd = {
      enable = true;
    };

    systemd.user.services.update-cli-caches = {
      Unit.Description = "Update tldr pages and television channels";
      Service = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.tealdeer}/bin/tldr --update"
          "${pkgs.television}/bin/tv update-channels"
        ];
      };
    };

    systemd.user.timers.update-cli-caches = {
      Unit.Description = "Weekly tldr/television cache update";
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnCalendar = "weekly";
        Persistent = true; # run on boot if the slot was missed
        RandomizedDelaySec = "1h";
      };
    };
  };

  flake.nixosModules.desktop =
    {
      pkgs,
      config,
      ...
    }:
    # let
    #   selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    # in
    {

      imports = with self.nixosModules; [

        plymouth
        xdg

        sddm
        stylix

        ghostty
        kitty

        dms
        hyprland

        niri
        mangowc

        zen
        chromium
        bitwarden

        devtools
        opencode
      ];

      home-manager.users.${config.preferences.user.name} = {
        imports = with self.homeModules; [
          git
          lazyvim

          desktop-services
          vesktop
        ];
      };

      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.fira-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.noto
        nerd-fonts.symbols-only
        noto-fonts-color-emoji
      ];

      fonts.fontconfig.defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Fira Mono Nerd Font" ];
      };

      services = {
        gvfs.enable = true;
        udisks2.enable = true;
        tailscale.enable = true;
      };

      programs.firefox.enable = true;

      programs.winbox = {
        enable = true;
        openFirewall = true;

        # Inject the environment variable using makeWrapper instead of altering a desktop file
        package = pkgs.winbox.overrideAttrs (oldAttrs: {
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

          postInstall = (oldAttrs.postInstall or "") + ''
            wrapProgram $out/bin/WinBox \
              --set QT_QPA_PLATFORM xcb
          '';
        });
      };

      environment.pathsToLink = [ "share/thumbnailers" ];

      # environment.sessionVariables = {
      #   # https://stacker.news/items/948469
      #   NEWT_COLORS = "root=lavender,crust border=sapphire,base window=overlay0,base title=rosewater,crust button=surface2,lavender button_active=crust,maroon";
      #   QT_QPA_PLATFORM = "xcb";
      # };

      environment.systemPackages = with pkgs; [

        bibata-cursors-translucent
        bibata-cursors
        papirus-icon-theme
        quickshell
        cliphist
        wl-clipboard
        wl-clip-persist

        # General apps
        anydesk
        evince
        file-roller
        foliate
        galculator
        nautilus
        networkmanagerapplet
        pavucontrol
        tailscale
        udiskie
        udisks2
        wireguard-tools

        # Maybe
        google-chrome
        vscode

        # Dev Apps
        zed-editor
        sqlitebrowser

        # Multimedia
        cava
        mpd
        rmpc
        mpv
        feh
        vlc

        ffmpeg-full
        yt-dlp
      ];
    };
}
