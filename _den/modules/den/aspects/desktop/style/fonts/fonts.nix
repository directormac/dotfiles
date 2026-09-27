{den, ...}: {
  den.aspects.desktop.style.fonts = {
    includes = [
      den.aspects.desktop.style.fonts.nerd-fonts
      den.aspects.desktop.style.fonts.regular
    ];

    nixos = {
      fonts = {
        enableDefaultPackages = true;

        fontDir.enable = true;

        fontconfig = {
          enable = true;
          useEmbeddedBitmaps = true;
          defaultFonts = {
            monospace = ["Monaspace Neon NF"];
            sansSerif = ["Inter"];
            serif = ["Source Serif"];
            emoji = ["Noto Color Emoji"];
          };
        };
      };
    };

    homeManager = {
      fonts.fontconfig.enable = true;
    };
  };
}
