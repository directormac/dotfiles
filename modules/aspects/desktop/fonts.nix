# Desktop Fonts Leaf Aspect
{ den, ... }:
{
  den.aspects.desktop.fonts = {
    nixos =
      { pkgs, ... }:
      {
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

        fonts.fontconfig.defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "Fira Mono Nerd Font" ];
        };
      };
  };
}
