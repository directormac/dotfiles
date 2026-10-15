# XDG Portal, Mime Types, and User Directories Leaf Aspect
{
  core,
  den,
  ...
}:
{
  den.aspects.desktop.xdg = {
    nixos =
      { ... }:
      {
        environment.pathsToLink = [
          "/share/xdg-desktop-portal"
          "/share/applications"
        ];
      };

    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        xdg = {
          enable = true;

          userDirs = {
            enable = true;
            createDirectories = true;
            extraConfig = {
              XDG_CODE_DIR = "${config.home.homeDirectory}/Code";
              XDG_WORK_DIR = "${config.home.homeDirectory}/Work";
            };
          };

          mimeApps = {
            enable = true;
            defaultApplications = {
              "image/*" = [ "feh.desktop" ];
              "video/*" = "vlc.desktop";
              "video/*,.mkv" = "vlc.desktop";
              "text/plain" = "neovim.desktop";
              "inode/directory" = "org.gnome.Nautilus.desktop";
              "application/epub+zip" = "com.github.johnfactotum.Foliate.desktop";
              "application/pdf" = "org.gnome.Evince.desktop";
              "x-scheme-handler/http" = "zen-beta.desktop";
              "x-scheme-handler/https" = "zen-beta.desktop";
              "x-scheme-handler/discord" = "vesktop.desktop";
              "application/zip" = "org.gnome.FileRoller.desktop";
              "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
              "application/x-tar" = "org.gnome.FileRoller.desktop";
              "application/x-bzip2" = "org.gnome.FileRoller.desktop";
              "application/x-gzip" = "org.gnome.FileRoller.desktop";
              "application/x-xz" = "org.gnome.FileRoller.desktop";
              "application/x-rar" = "org.gnome.FileRoller.desktop";
              "application/rar" = "org.gnome.FileRoller.desktop";
            };

            associations.added = {
              "text/plain" = [ "neovim.desktop" ];
              "inode/directory" = [ "superfile.desktop" ];
              "video/*" = [
                "mpv.desktop"
                "vlc-new-window.desktop"
                "vlc-enqueue.desktop"
              ];
              "audio/*" = [
                "mpv.desktop"
                "vlc-new-window.desktop"
                "vlc-enqueue.desktop"
              ];
            };
          };

          portal = {
            enable = true;
            xdgOpenUsePortal = true;
            config = {
              common = {
                default = [ "gtk" ];
                "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
              };
              gnome = {
                default = [
                  "gnome"
                  "gtk"
                ];
              };
              hyprland = {
                default = [
                  "hyprland"
                  "gtk"
                ];
                "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
                "org.freedesktop.impl.portal.RemoteDesktop" = [ "hypr_kdeconnect" ];
              };
              kde = {
                default = [
                  "kde"
                  "gtk"
                ];
                "org.freedesktop.portal.FileChooser" = [ "kde" ];
                "org.freedesktop.portal.OpenURI" = [ "kde" ];
              };
              niri = {
                "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
                "org.freedesktop.impl.portal.Access" = [ "gtk" ];
                "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
                "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
                "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
                "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
              };
              mango = {
                default = [ "gtk" ];
                "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
                "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
                "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
                "org.freedesktop.impl.portal.Inhibit" = [ "none" ];
              };
              sway = {
                default = [
                  "gtk"
                  "wlr"
                ];
              };
            };
            extraPortals = [
              pkgs.xdg-desktop-portal-gtk
              pkgs.xdg-desktop-portal-gnome
              pkgs.xdg-desktop-portal-hyprland
              pkgs.kdePackages.xdg-desktop-portal-kde
              pkgs.xdg-desktop-portal-wlr
              pkgs.local.hypr-kdeconnect-fix
            ];
          };
        };

        home.file = {
          ".face".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/.face";
          ".config/wallpapers".source =
            config.lib.file.mkOutOfStoreSymlink "${dotsPath}/wallpapers";
        };
      };
  };

}
