{pkgs, ...}: {
  den.aspects.base.localization.console = {
    nixos = _: {
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
