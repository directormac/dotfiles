{ config, pkgs, ... }: {

  xdg = {
    enable = true;
    cacheHome = config.home.homeDirectory + "/.local/cache";

    mimeApps = { enable = true; };

    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };

    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      xdgOpenUsePortal = true;
    };

  };

}
