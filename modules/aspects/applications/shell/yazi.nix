# Yazi Terminal File Manager Leaf Aspect
_:
{
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

          plugins = {
            mount = pkgs.yaziPlugins.mount;
            git = pkgs.yaziPlugins.git;
            mdv-previewer = pkgs.fetchFromGitHub {
              owner = "WhoSowSee";
              repo = "mdv-previewer.yazi";
              rev = "099ebba";
              hash = "sha256-iYPhBzbaCS8IM39/Flai02AA8OJgl2Ue2nB2sKqTbZY=";
            };
          };

          extraPackages = with pkgs; [
            util-linux
            udisks
          ];
        };

        xdg.configFile = builtins.listToAttrs (
          map (name: {
            name = "yazi/${name}";
            value.source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/yazi/${name}";
          }) [
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
