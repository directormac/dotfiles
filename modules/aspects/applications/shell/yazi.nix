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
    yazi-plugin-supaline = {
      flake = false;
      url = "github:yohkuri/supaline.yazi";
    };
    yazi-plugin-center-media = {
      flake = false;
      url = "github:ENEmyr/center-media.yazi";
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
          gnome-epub-thumbnailer
          sshfs
          archivemount
          mediainfo
          resvg
          pigz
          pbzip2
          pixz
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
            gnome-epub-thumbnailer
            sshfs
            archivemount
            mediainfo
            resvg
            pigz
            pbzip2
            pixz
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
            sshfs = pkgs.yaziPlugins.sshfs;
            keep-preferences = pkgs.yaziPlugins.keep-preferences;

            supaline =
              inputs.yazi-plugin-supaline or (pkgs.fetchFromGitHub {
                hash = "sha256-nrdppocG+4GV8NEf5+aUFRrjbf+vJe9gPZ4yt7loRG4=";
                owner = "yohkuri";
                repo = "supaline.yazi";
                rev = "867df699f46ce12c66ee53585cda3d97ee8c0aea";
              });

            center-media =
              inputs.yazi-plugin-center-media or (pkgs.fetchFromGitHub {
                hash = "sha256-HvS2kKhXLrReHz+bVfATS47vmZFcVS8oVD8FOhc2QHk=";
                owner = "ENEmyr";
                repo = "center-media.yazi";
                rev = "3fca3a5cc0678c72810cac38309c4355c96af99f";
              });
          };
        };

        xdg.configFile =
          builtins.listToAttrs (
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
          )
          // builtins.listToAttrs (
            map
              (plugin: {
                name = "yazi/plugins/${plugin}";
                value.source = config.lib.dots.link "yazi/plugins/${plugin}";
              })
              [
                "bypass.yazi"
                "smart-enter.yazi"
                "epub-preview.yazi"
                "ffmpeg-stats.yazi"
                "archive-mount.yazi"
                "archives.yazi"
                "flash.yazi"
                "responsive-layout.yazi"
                "difftool.yazi"
                "yafg.yazi"
              ]
          );
      };

    persistHome.directories = [
      ".local/state/yazi"
    ];
  };
}
