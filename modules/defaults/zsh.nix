# [zsh.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/zsh/default.nix)
# [zsh.options](https://search.nixos.org/options?channel=unstable&query=programs.zsh&source=home_manager&type=options)
{
  lib,
  pkgs,
  ...
}: {
  den.default.homeManager.programs.zsh = {
    enable = true;

    enableBashCompletion = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    fastSyntaxHighlighting.enable = true;
    historySubstringSearch.enable = false;

    history = {
      saveNoDups = true;
      findNoDups = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
    };

    shellAliases = {
      dotfiles = "cd ~/.dotfiles";
      c = "clear";
      cat = lib.getExe pkgs.bat;
      cd = "z";
      cda = "zoxide add";
      cdq = "zoxide query";
      cdr = "zoxide remove";
      ci = "zi";
      du = lib.getExe pkgs.dust;
      find = lib.getExe pkgs.fd;
      grep = lib.getExe pkgs.ripgrep;
      l = "${lib.getExe pkgs.lsd} -a";
      la = "${lib.getExe pkgs.lsd} -la";
      lg = lib.getExe pkgs.lazygit;
      ls = "${lib.getExe pkgs.lsd} -l";
      lt = "${lib.getExe pkgs.lsd} --tree";
      man = "man -P \"${lib.getExe pkgs.bat} -p\"";
      nsh = "nix-shell -p";
      flakecheck = "nix flake check ~/.dotfiles";
      nrsf = "sudo nixos-rebuild switch --flake ~/.dotfiles";
      top = lib.getExe pkgs.btop;
      wh = "which";
      y = lib.getExe pkgs.yazi;
    };
  };
}
