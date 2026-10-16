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
          autosuggestions.enable = false;
          enable = lib.mkDefault true;
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
        user,
        ...
      }:
      let
        aliases = import ./zsh/_aliases.nix;
        completion = import ./zsh/_completion.nix;
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
        functions = import ./zsh/_functions.nix { inherit config; };
        histdb = import ./zsh/_histdb.nix { inherit config pkgs; };
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
          autosuggestion.enable = true;
          inherit (completion) completionInit;
          enable = true;
          enableCompletion = true;
          inherit (completion) fastSyntaxHighlighting;

          history = {
            ignoreAllDups = true;
            save = 0;
            size = 100000;
          };

          initContent =
            # zsh
            ''
              ${histdb.initContent}
              ${functions}
              ${completion.fzfTabZstyle}

              function zvm_after_init() {
                ${histdb.zvmKeybindings}

                # Autosuggest Accept Keybindings (Ctrl+Tab only)
                zvm_bindkey viins '^[[27;5;9~' autosuggest-accept
                zvm_bindkey viins '^[[1;5I' autosuggest-accept
                zvm_bindkey viins '^[[9;5u' autosuggest-accept
              }

              eval "$(devenv hook zsh)"
              source $XDG_CONFIG_HOME/zsh/extra.zsh
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
            MANPAGER = "sh -c 'col -bx | bat -l man -p'";
            MANROFFOPT = "-c";
            NEWT_COLORS = "root=lavender,crust border=sapphire,base window=overlay0,base title=rosewater,crust button=surface2,lavender button_active=crust,maroon";
          };

          shellAliases = aliases;
          syntaxHighlighting.enable = false;
        };

        xdg.configFile."fsh".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/fsh";
        xdg.configFile."television/cable/zsh-keys.toml".text = keys.televisionCableToml;

        xdg.configFile."zsh/extra.zsh".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/zsh/extra.zsh";
      };

    persistHome = {
      directories = [
        ".local/share/zsh"
        ".histdb"
      ];

    };
  };
}
