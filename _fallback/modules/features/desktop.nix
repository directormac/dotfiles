{ self, ... }: {
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

      imports = [
        self.nixosModules.xdg
        self.nixosModules.greeter

        self.nixosModules.dms
        self.nixosModules.hyprland

        self.nixosModules.zen
        self.nixosModules.niri
        self.nixosModules.mangowc
      ];

      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.vesktop
        ];
      };

      programs.firefox.enable = true;

      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.fira-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.noto
        nerd-fonts.symbols-only
      ];

      fonts.fontconfig.defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Fira Mono Nerd Font" ];
      };

      environment.systemPackages = with pkgs; [
        quickshell
        cliphist
        wl-clipboard

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

        ffmpeg-full
        yt-dlp

        kitty
        ghostty

        self.packages."${pkgs.stdenv.hostPlatform.system}".nh
      ];
    };
}
