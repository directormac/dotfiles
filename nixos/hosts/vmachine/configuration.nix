{ self, inputs, ... }: {
  flake.nixosModules.vmachineConfiguration = { pkgs, lib, ... }: {

    imports = [
      self.nixosModules.vmachineHardware
      self.nixosModules.nocturnal-niri
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

    services.displayManager = {
      autoLogin = {
        enable = true;
        user = "artifex";
      };
    };

    environment = {
      systemPackages = with pkgs; [
        github-cli
        quickshell
        inputs.zen-browser.packages."${system}".default
        vim
        wget
        foot
        neovim
        lua-language-server
        stylua
        ghostty
        tmux
        nil
        nixfmt
        wl-clipboard
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

    fileSystems."/home/artifex/Public/vshared" = {
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

    services = {

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
      ];

      # dconf.settings = {
      #   "org/gnome/desktop/interface" = {
      #     color-scheme = "prefer-dark";
      #   };
      # };

      # packages = with pkgs; [
      #   #  thunderbird
      # ];
    };

    # home-manager.users."artifex" = self.homeModules.artifex;

    # Select internationalisation properties.
    i18n.defaultLocale = "en_PH.UTF-8";
    security.rtkit.enable = true;

    system.stateVersion = "26.05";
  };
}
