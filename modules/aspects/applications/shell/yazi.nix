# Yazi Terminal File Manager Leaf Aspect
{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    yazi-plugin-mdv-previewer = {
      flake = false;
      url = "github:WhoSowSee/mdv-previewer.yazi";
    };
  };

  den.aspects.applications.shell.yazi = {
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
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
        ];

        programs.yazi = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;

          extraPackages = with pkgs; [
            util-linux
            udisks
          ];

          plugins = {
            git = pkgs.yaziPlugins.git;

            mdv-previewer =
              inputs.yazi-plugin-mdv-previewer or (pkgs.fetchFromGitHub {
                hash = "sha256-iYPhBzbaCS8IM39/Flai02AA8OJgl2Ue2nB2sKqTbZY=";
                owner = "WhoSowSee";
                repo = "mdv-previewer.yazi";
                rev = "099ebba";
              });

            mount = pkgs.yaziPlugins.mount;
          };
        };

        xdg.configFile = builtins.listToAttrs (
          map
            (name: {
              name = "yazi/${name}";
              value.source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/yazi/${name}";
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
