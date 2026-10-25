# Zsh HistDB & Skim Integration
# Larkery's zsh-histdb (SQLite history tracker) + m42e's zsh-histdb-skim (Rust/Skim interactive finder)
{ pkgs }:
let
  histdbPkg = pkgs.local.zsh-histdb or pkgs.zsh-histdb;
  skimHistdbPkg = pkgs.local.zsh-skim-histdb or pkgs.zsh-skim-histdb;
in
{

  packages = [
    pkgs.sqlite
    skimHistdbPkg
    histdbPkg
  ];

  persistDirectories = [
    ".local/share/zsh"
    ".histdb"
  ];

  plugins = [
    {
      file = "sqlite-history.zsh";
      name = "zsh-histdb";
      src = "${histdbPkg}/share/zsh-histdb";
    }
    {
      file = "histdb-fzf.zsh";
      name = "zsh-histdb-fzf";
      src = "${histdbPkg}/share/zsh-histdb";
    }
    {
      file = "zsh-histdb-skim.plugin.zsh";
      name = "zsh-histdb-skim";
      src = "${skimHistdbPkg}/share/zsh-histdb-skim";
    }
  ];

}
