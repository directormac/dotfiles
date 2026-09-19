{
  den,
  lib,
  ...
}: {
  den.aspects.base.localization.console = {
    nixos = {pkgs, ...}: {
      console = {
        font = "ter-114n";
        keyMap = "us";
        packages = with pkgs; [
          terminus_font
        ];
      };
    };
  };
}
