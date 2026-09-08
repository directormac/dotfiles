{ self, inputs, ... }: {
  flake.nixosModules.vmachineConfiguration = { pkgs, lib, ... }: {

    imports = [
      self.nixosModules.vmachineHardware
      # self.nixosModules.nocturnal-niri
      self.nixosModules.niri
      self.nixosModules.sddm
      self.nixosModules.git
      self.nixosModules.zsh
    ];

    boot = {
      loader = {
        # Use the systemd-boot EFI boot loader.
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 4;
        efi.canTouchEfiVariables = true;
      };

      # Use latest kernel.
      kernelPackages = pkgs.linuxPackages_latest;
    };

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      nerd-fonts.noto
      nerd-fonts.fira-mono

    ];

    programs.firefox.enable = true;

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
            };
          };
        }
      ];
    };
    services = {

      displayManager = {
        autoLogin = {
          enable = true;
          user = "artifex";
        };
      };

      spice-vdagentd.enable = true;

      # Enable the GNOME Desktop Environment.
      # displayManager.gdm.enable = true;
      # desktopManager.gnome.enable = true;

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
        };
      };

      # Configure keymap in X11
      xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable sound with pipewire.
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # Use the WirePlumber session manager
        #wireplumber.enable = true;
      };

    };

    environment = {
      systemPackages = with pkgs; [
        # Desktop
        quickshell
        inputs.zen-browser.packages."${system}".default
        foot
        ghostty
        wl-clipboard
        pavucontrol

        # Wrapped
        self.packages."${pkgs.system}".kittyfish
        self.packages."${pkgs.system}".my-vim
        self.packages."${pkgs.system}".noctalia
      ];

      sessionVariables = {
        EDITOR = "nvim";
        WLR_NO_HARDWARE_CURSORS = "1";
      };

      shellAliases = {
        # nrsf = "sudo nixos-rebuild switch --flake /etc/nixos";
        # nixconf = "sudoedit /etc/nixos/configuration.nix";
      };
    };

    fileSystems."/home/artifex/Public" = {
      device = "vshare";
      fsType = "virtiofs";
      options = [ "defaults" ];
    };

    fileSystems."/home/artifex/.dotfiles" = {
      device = "vdotfiles";
      fsType = "virtiofs";
      options = [ "defaults" ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    networking.hostName = "vmachine"; # Define your hostname.

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Asia/Manila";

    users.users."artifex" = {
      isNormalUser = true;
      description = "artifex";
      extraGroups = [
        "root"
        "networkmanager"
        "wheel"
        "libvirt"
        "libvirt-qemu"
        "kvm"
      ];
    };

    home-manager.users.artifex =
      { config, lib, ... }:
      let
        # Define where your flake lives on the live filesystem
        flakePath = "${config.home.homeDirectory}/.dotfiles";
      in
      {
        home.stateVersion = "26.05";
        home.file = {

          ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/ghostty";

          ".config/kitty/kitty.conf".source =
            config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/kitty/kitty.conf";

          ".config/bat".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/bat";

          ".config/vim".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/vim";

          ".config/yazi".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/yazi";

          ".config/noctalia".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/noctalia";

          ".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/niri";

          ".config/wallpapers".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/wallpapers";
        };

        systemd.user.services.spice-vdagent = {
          Unit = {
            Description = "Spice guest desktop agent";
            PartOf = [ "graphical-session.target" ];
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x";
          };
        };
      };

    # Select internationalisation properties.
    i18n.defaultLocale = "en_PH.UTF-8";
    security.rtkit.enable = true;

    system.stateVersion = "26.05";
  };
}
