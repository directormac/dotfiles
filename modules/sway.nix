{ inputs, pkgs, ... }: {


  imports =
    [ ../home/programs/desktop.nix ];

  environment.systemPackages = with pkgs; [
    hyprpicker
    swayidle 
    swaylock 
    grim
    slurp
    wl-clipboard
    cliphist
    swaynotificationcenter
    waybar
    rofi
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";

    NIXOS_OZON_WL = "1";
  };


  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };



  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
  };
  
  home.file."./.config/sway/" = {
    source = ../.config/sway;
    recursive = true;
  };

  home.file."./.config/sway/scripts/" = {
    source = ../.config/sway/scripts;
    recursive = true;
    fileMode = "0755";
  };

  home.file."~/.config/bat/" = {
    source = "~/.dotfiles/.config/bat";
    recursive = true;
  };



}
