{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.zsh = moduleWithSystem (
    {
      pkgs,
      self',
      ...
    }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          inherit (self'.packages) zsh;
        })
      ];
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        histSize = 100000;
      };
      users.defaultUserShell = pkgs.zsh;
    }
  );
  perSystem =
    {
      pkgs,
      self',
      lib,
      flakeLocation,
      ...
    }:
    {
      packages = {
        zsh = inputs.wrapper-modules.wrappers.zsh.wrap {
          inherit pkgs;
          runtimePkgs = [
            pkgs.devenv
            pkgs.fzf
            pkgs.starship
          ];
          zshAliases = {
            l = "${lib.getExe pkgs.lsd} -a";
            la = "${lib.getExe pkgs.lsd} -la";
            ls = "${lib.getExe pkgs.lsd} -l";
            lt = "${lib.getExe pkgs.lsd} --tree";
            cd = "z";
            ci = "zi";
            cat = lib.getExe pkgs.bat;
            lg = lib.getExe pkgs.lazygit;
            man = "man -P \"${lib.getExe pkgs.bat} -p\"";
            nsh = "nix-shell -p";
            wh = "which";
            du = lib.getExe pkgs.dust;
            top = lib.getExe pkgs.btop;
            grep = lib.getExe pkgs.ripgrep;
            y = lib.getExe pkgs.yazi;
            find = lib.getExe pkgs.fd;
            cda = "zoxide add";
            cdq = "zoxide query";
            cdr = "zoxide remove";
          };

          zshrc.content = ''

            export LS_COLORS="$(${lib.getExe pkgs.vivid} generate catppuccin-mocha)"
            export EDITOR=nvim
            export TERMINAL=ghostty

            eval "$(${lib.getExe pkgs.devenv} hook zsh)"
            eval "$(${lib.getExe pkgs.starship} init zsh)"
            eval "$(${lib.getExe pkgs.zoxide} init zsh)"
          '';
        };
      };
    };
}
