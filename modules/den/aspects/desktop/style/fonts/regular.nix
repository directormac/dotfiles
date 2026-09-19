{den, ...}: {
  den.aspects.desktop.style.fonts.regular = {
    includes = [
      (den.batteries.unfree [
        "corefonts"
        "vista-fonts"
      ])
    ];

    nixos = {pkgs, ...}: {
      fonts.packages = with pkgs; [
        adwaita-fonts
        # aporetic
        atkinson-hyperlegible-next
        corefonts
        dejavu_fonts
        dina-font
        fira
        font-awesome
        googlesans-code
        inter
        jetbrains-mono
        libertine
        maple-mono.NF

        material-icons
        material-symbols
        openmoji-color

        monaspace
        montserrat
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        source-code-pro
        twitter-color-emoji
        # twemoji-color-font
        vista-fonts
      ];
    };
  };
}
