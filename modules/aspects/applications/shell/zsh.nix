# Zsh Interactive Shell Leaf Aspect
{
  den.aspects.applications.shell.zsh = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.pathsToLink = [ "/share/zsh" ];

        environment.systemPackages = with pkgs; [
          tree
        ];

        programs.zsh = {
          enable = lib.mkDefault true;
          autosuggestions.enable = false;
          enableBashCompletion = true;
          enableCompletion = true;
          histSize = 100000;
          syntaxHighlighting.enable = false;
        };

        users.defaultUserShell = pkgs.zsh;
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        completion = import ./zsh/_completion.nix;
        histdb = import ./zsh/_histdb.nix { inherit pkgs; };
        keys = import ./zsh/_keys.nix { inherit pkgs; };
      in
      {
        home.packages =
          with pkgs;
          [
            lsd
            keys.zsh-list-keys-tv
          ]
          ++ histdb.packages;

        programs.zsh = {
          inherit (completion) completionInit;
          inherit (completion) fastSyntaxHighlighting;
          enable = true;
          autosuggestion.enable = true;
          enableCompletion = true;

          history = {
            ignoreAllDups = true;
            save = 0;
            size = 100000;
          };

          initContent =
            # zsh
            ''
              source "''${XDG_CONFIG_HOME:-$HOME/.config}/zsh/init-content.zsh"
            '';

          plugins = [
            {
              file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
              name = "zsh-vi-mode";
              src = pkgs.zsh-vi-mode;
            }
            {
              file = "share/fzf-tab/fzf-tab.plugin.zsh";
              name = "fzf-tab";
              src = pkgs.zsh-fzf-tab;
            }
          ]
          ++ histdb.plugins;

          sessionVariables = {
            BROWSER = "zen-beta";
            EDITOR = "nvim";
            MANPAGER = "sh -c 'col -bx | bat -l man -p --paging=always'";
            MANROFFOPT = "-c";
            NEWT_COLORS = "root=lavender,crust border=sapphire,base window=overlay0,base title=rosewater,crust button=surface2,lavender button_active=crust,maroon";
          };

          syntaxHighlighting.enable = false;
        };

        xdg.configFile."fsh".source = config.lib.dots.link "fsh";
        xdg.configFile."television/cable/zsh-keys.toml".text = keys.televisionCableToml;
        xdg.configFile."zsh/aliases.zsh".source = config.lib.dots.link "zsh/aliases.zsh";
        xdg.configFile."zsh/functions.zsh".source = config.lib.dots.link "zsh/functions.zsh";
        xdg.configFile."zsh/init-content.zsh".source = config.lib.dots.link "zsh/init-content.zsh";
      };

    persistHome = {
      directories = [
        ".local/share/zsh"
        ".histdb"
      ];

    };
  };
}
