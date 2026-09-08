{ self, inputs, ... }: {
  flake.nixosModules.desktop =
    { pkgs, config, ... }:
    let
      selfpkgs = self.packages."${pkgs.system}";
    in
    {
      imports = [
        self.nixosModules.gtk

        self.nixosModules.lazyvim
        self.nixosModules.wshowkeys
        self.nixosModules.sddm
      ];

      programs.niri.enable = true;
      programs.niri.package = selfpkgs.niri;

      preferences.lazyvim.enable = true;
      # preferences.autostart = [selfpkgs.quickshellWrapped];
      # preferences.autostart = [ selfpkgs.noctalia-shell ];

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
          selfpkgs.kittyfish
          selfpkgs.noctalia
        ];

        sessionVariables = {
          EDITOR = "nvim";
          WLR_NO_HARDWARE_CURSORS = "1";
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
        serif = [ "Noto Sans" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Fira Mono Nerd Font" ];
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
