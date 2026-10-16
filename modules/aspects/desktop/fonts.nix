# Desktop Fonts Leaf Aspect
{
  den.aspects.desktop.fonts = {
    nixos =
      { pkgs, ... }:
      {
        fonts.fontconfig.defaultFonts = {
          monospace = [ "Fira Mono Nerd Font" ];
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
        };

        fonts.packages = with pkgs; [
          nerd-fonts.fira-code
          nerd-fonts.fira-mono
          nerd-fonts.jetbrains-mono
          nerd-fonts.noto
          nerd-fonts.symbols-only
          noto-fonts
          noto-fonts-color-emoji
          corefonts
          unifont
          cm_unicode
        ];
      };
  };
}
