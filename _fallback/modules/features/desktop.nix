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
          tray = "auto";
          automount = true;
          notify = true;
          udisks_version = 2;
          # file_manager = "${pkgs.nautilus}/bin/nautilus";
        };

        device_config = [
          {
            # Match all virtual loop structures (used for mounting ISO/IMG files)
            match = {
              device_file = "/dev/loop*";
            };
            options = {
              detach = true; # Tells udiskie to break down the loop device cleanly
              eject = true; # Erases the phantom block instance from the kernel
            };
          }
        ];

      };
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
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {

      imports = with self.nixosModules; [

        plymouth
        xdg
        agenix

        sddm
        stylix

        ghostty
        kitty

        dms
        hyprland

        niri
        mangowc

        browser
        chromium
        bitwarden

        devtools
        opencode
        rmpd
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
        # devmon.enable = true;

        libinput.enable = true;
        fstrim.enable = true;
        gvfs.enable = true;
        udisks2.enable = true;
        dbus.enable = true;
        blueman.enable = true;
        tumbler.enable = true;
        gnome.gnome-keyring.enable = true;
        tailscale.enable = true;
        printing.enable = true;
        pulseaudio.enable = false;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          # If you want to use JACK applications, uncomment this
          jack.enable = true;

          extraConfig.pipewire."92-low-latency" = {
            "context.properties" = {
              "default.clock.rate" = 44100;
              "default.clock.allowed-rates" = [
                44100
                48000
                88200
                96000
                176400
                192000
                352800
                384000
              ];
              "default.clock.quantum" = 512;
              "default.clock.min-quantum" = 32;
              "default.clock.max-quantum" = 2048;
            };
          };
          extraConfig.pipewire-pulse."92-low-latency" = {
            context.modules = [
              {
                name = "libpipewire-module-protocol-pulse";
                args = {
                  "pulse.min.req" = "32/44100";
                  "pulse.default.req" = "512/44100";
                  "pulse.max.req" = "2048/44100";
                  "pulse.min.quantum" = "32/44100";
                  "pulse.max.quantum" = "2048/44100";
                };
              }
            ];
          };

          # use the example session manager (no others are packaged yet so this is enabled by default,
          # no need to redefine it in your config for now)
          #media-session.enable = true;
        };

        # Enable the X11 windowing system.
        xserver = {
          enable = true;

          exportConfiguration = true;

          excludePackages = [ pkgs.xterm ]; # Erases xterm completely!

          xkb = {
            layout = "us";
            variant = "";
          };

        };

      };

      # Enable the GNOME Desktop Environment.
      # services.displayManager.gdm.enable = true;
      # services.desktopManager.gnome.enable = true;

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      programs = {
        xfconf.enable = true;
        fuse.userAllowOther = true;
        mtr.enable = true;
        gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
      };

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

      environment.systemPackages = with pkgs; [
        android-tools
        anydesk
        cava
        cliphist
        evince
        feh
        ffmpeg-full
        ffmpegthumbnailer # High-performance video thumbs (MKV, MP4, HEVC, AV1)
        file-roller
        foliate
        galculator
        gdk-pixbuf # Fixes raw image asset translations
        gnome-disk-utility
        google-chrome
        libgsf # Explodes ODF and open-office document formats
        libinput
        libjxl
        localsend
        mpv
        nautilus
        pavucontrol
        poppler-utils # Lightning-fast PDF thumbnails
        quickshell
        rmpc
        seahorse
        selfpkgs.rmpd
        sqlitebrowser
        tailscale
        tor-browser
        udiskie
        udisks2
        vlc
        vscode
        vulkan-tools
        webp-pixbuf-loader # Ensures .webp images show clean previews
        wev
        wireguard-tools
        wl-clip-persist
        wl-clipboard
        xdg-utils
        yt-dlp
        zed-editor

        # gnumake
        # gcc
        # binutils
        # pkg-config
        # imagemagickBig
        # losslessaudiochecker
        # novelwriter
        # sox
        # sox_ng
        # spek
      ];
    };
}
