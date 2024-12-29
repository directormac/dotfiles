{
lib,
pkgs,
...
}:{

home.packages = with pkgs; [
# Archives
zip
unzip
p7zip

# Utilities
ripgrep
jq
htop
aria2

# Misc
libnotify
xdg-utils


mycli
pgcli

];

programs = {
 tmux = {
  enable = true;
  clock24 = true;
  keyMode = "vi";
  extraConfig = "mouse on";
 };

 btop.enable = true;
 lsd.enable = true;
 ssh.enable = true;
 zoxide.enable = true;
 

};

sertvies = {
udiskie.eable = true;
};

}
