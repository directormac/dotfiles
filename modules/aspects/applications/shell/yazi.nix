# Yazi Terminal File Manager Leaf Aspect
{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    yazi-plugin-whoosh = {
      flake = false;
      url = "github:WhoSowSee/whoosh.yazi";
    };
  };

  den.aspects.applications.shell.yazi = {
    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      {
        home.packages = with pkgs; [
          file
          jq
          fd
          ripgrep
          fzf
          zoxide
          ffmpegthumbnailer
          unar
          p7zip
          imagemagick
          util-linux
          udisks
          trash-cli
          ouch
          nushell
        ];

        programs.yazi = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;

          extraPackages = with pkgs; [
            util-linux
            udisks
            trash-cli
            ouch
            nushell
          ];

          plugins = {
            close-and-restore-tab = pkgs.yaziPlugins.close-and-restore-tab;
            compress = pkgs.yaziPlugins.compress;
            git = pkgs.yaziPlugins.git;
            kdeconnect-send = pkgs.yaziPlugins.kdeconnect-send;
            lazygit = pkgs.yaziPlugins.lazygit;

            mount = pkgs.yaziPlugins.mount;
            omni-trash = pkgs.yaziPlugins.omni-trash;
            ouch = pkgs.yaziPlugins.ouch;
            projects = pkgs.yaziPlugins.projects;
            split-tabs = pkgs.yaziPlugins.split-tabs;
            starship = pkgs.yaziPlugins.starship;
            sudo = pkgs.yaziPlugins.sudo;
            toggle-pane = pkgs.yaziPlugins.toggle-pane;
            whoosh =
              inputs.yazi-plugin-whoosh or (pkgs.fetchFromGitHub {
                hash = "sha256-LwugSeuG3+PmPW9KFvRThqx+g792CmUnw+vY6wSZJoo=";
                owner = "WhoSowSee";
                repo = "whoosh.yazi";
                rev = "d6ede9895a0e14b1bb1d65cd0eb783f92f2fc522";
              });
            wl-clipboard = pkgs.yaziPlugins.wl-clipboard;
          };
        };

        xdg.configFile = builtins.listToAttrs (
          map
            (name: {
              name = "yazi/${name}";
              value.source = config.lib.dots.link "yazi/${name}";
            })
            [
              "yazi.toml"
              "keymap.toml"
              "theme.toml"
              "init.lua"
              "package.toml"
              "Catppuccin-Mocha.tmTheme"
            ]
        );
      };

    persistHome.directories = [
      ".local/state/yazi"
    ];
  };
}
