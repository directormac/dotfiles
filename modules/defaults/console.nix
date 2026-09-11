{
  den.default.nixos = {pkgs, ...}: {
    console = {
      font = "ter-114n";
      keyMap = "us";
      packages = with pkgs; [
        terminus_font
      ];
    };
  };
}
