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
  "generations" = "tv nix-generations";
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
  "lzr" = "lazyrsync";
  "nhg" = "tv nix-generations";
  "nho" = "nh os";
  "nixdev" = "nix develop";
  "nsh" = "nix-shell -p";
  "oc" = "opencode";
  "oc2" = "opencode2";
  "ocx" = "opencode --auto";
  "pingcf" = "ping 1.1.1.1";
  "pinggg" = "ping google.com";
  "rebuild" = "rebuild-switch";
  "rmr" = "rm -r";

  "t" =
    "TV_CMD=\"tv --layout portrait --hide-preview --input-position top\" tv --layout portrait --hide-preview --input-position top";

  "tls" = "tmux ls";
  "tn" = "sesh connect .";
  "todo" = "tuxedo";
  "top" = "btop";
  "ts" = "sesh last";
  "tv-inputs" = "tv flake-inputs";
  "tv-pkgs" = "tv update-pkgs";
  "tvk" = "tv zsh-keys";
  "v" = "nvim -c \"lua if vim.fn.argc() == 0 then require('persistence').load() end\"";
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
  "zen" = "zen-beta";
}
