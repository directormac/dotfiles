{
  den.default.homeManager = {pkgs, ...}: {
    programs.fzf = {
      enable = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type file";
      fileWidgetCommand = "${pkgs.fd}/bin/fd --type file";
    };
  };
}
