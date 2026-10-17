# Shell Aliases for Zsh
{
  "age" = "rage";
  "agyx" = "agy  --dangerously-skip-permissions";
  "c" = "clear";
  "cd" = "z";
  "cda" = "zoxide add";
  "cdq" = "zoxide query";
  "cdr" = "zoxide remove";
  "ci" = "zi";
  "dotfiles" = "cd ~/.dotfiles";
  "du" = "dust";
  "find" = "fd";
  "flake" = "nix flake";
  "grab" = "ghgrab --cwd";
  "grep" = "rg";
  "hdb" = "histdb";
  "hdbs" = "histdb-sync";
  "hdbt" = "histdb-top";
  "l" = "lsd -a";
  "la" = "lsd -la";
  "less" = "bat";
  "ll" = "lsd -l";
  "logs" = "journalctl --user -f -n 50";
  "ls" = "lsd";
  "lt" = "lsd --tree";
  "lzd" = "lazydocker";
  "lzg" = "lazygit";
  "lzm" = "lazymark";
  "nho" = "nh os";
  "nhg" = "tv nix-generations";
  "generations" = "tv nix-generations";
  "rebuild" = "rebuild-switch";
  "nixdev" = "nix develop";
  "nsh" = "nix-shell -p";
  "oc" = "opencode";
  "oc2" = "opencode2";
  "ocx" = "opencode --auto";
  "pingcf" = "ping 1.1.1.1";
  "pinggg" = "ping google.com";
  "rmr" = "rm -r";

  "t" =
    "TV_CMD=\"tv --layout portrait --hide-preview --input-position top\" tv --layout portrait --hide-preview --input-position top";

  "tls" = "tmux ls";
  "tn" = "sesh connect .";
  "todo" = "tuxedo";
  "top" = "btop";
  "ts" = "sesh last";
  "tvk" = "tv zsh-keys";
  "v" = "nvim";
  "vi" = "vim";
  "wh" = "which";
  "winbox" = "QT_QPA_PLATFORM=xcb WinBox | NUL";
  "wm" = "workmux";
  "wma" = "workmux add";
  "wmd" = "workmux dashboard -t worktrees";
  "wml" = "workmux list";
  "wmm" = "workmux merge";
  "wmo" = "workmux open";
  "wmq" = "workmux add --mode window --base main -l quickfix";
  "wms" = "workmux sidebar";
  "wmw" = "workmux add --mode window --base main -l agent-only";
  "y" = "yazi";
  "zen" = "zen-beta";
}
