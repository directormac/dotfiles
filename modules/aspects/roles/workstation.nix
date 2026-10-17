# Workstation Role: interactive desktop compositors, theming, desktop services, browsers, terminals, GUI apps, and virtualization
{ den, ... }:
{
  den.aspects.roles.workstation = {
    includes = with den.aspects; [
      # Desktop Compositors & Window Managers
      desktop.greeter
      desktop.hyprland
      desktop.niri
      desktop.mangowm
      desktop.dms

      # Desktop Environment, Audio, Theming & File Management
      desktop.audio
      desktop.fonts
      desktop.gtk
      desktop.kdeconnect
      desktop.nautilus
      desktop.stylix
      desktop.thunar
      desktop.udiskie
      desktop.xdg
      desktop.xserver

      # Web Browsers
      applications.browsers.zen
      applications.browsers.firefox
      applications.browsers.librewolf
      applications.browsers.chromium
      applications.browsers.tor-browser

      # Terminal Emulators
      applications.terminals.ghostty
      applications.terminals.kitty
      applications.terminals.foot

      # Wayland Utilities
      applications.wayland.wl-kbptr
      applications.wayland.fuzzel
      applications.wayland.cliphist
      applications.wayland.quickshell
      applications.wayland.fcitx5

      # Media & Messaging
      applications.media.mpv
      applications.media.vlc
      applications.media.rmpd
      applications.media.cava
      applications.media.yt-dlp
      applications.media.imv
      applications.media.feh
      applications.media.mpvpaper
      applications.messaging.vesktop

      # Productivity & Utilities
      applications.productivity.tuxedo
      applications.productivity.evince
      applications.productivity.foliate
      applications.productivity.galculator
      applications.productivity.zennotes
      applications.productivity.torlink
      applications.productivity.localsend
      applications.productivity.anydesk
      applications.productivity.scrcpy
      applications.productivity.obsidian

      # Virtualization
      virtualization.libvirt
      virtualization.podman
      virtualization.waydroid
    ];
  };
}
