{ self, ... }:
{
  # Declared once here; the flake-parts wrappers module turns this into
  # outputs.wrappers.yazi and packages.<system>.yazi (in-store config).
  flake.wrappers.yazi =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      options.configDir = lib.mkOption {
        type = lib.types.either lib.types.str lib.types.path;
        default = ../../../config/yazi;
        description = "Yazi config directory (YAZI_CONFIG_HOME). Defaults to the in-store copy; hosts override it with the live checkout.";
      };

      config.package = pkgs.yazi;
      config.envDefault.YAZI_CONFIG_HOME = "${config.configDir}";
      config.runtimePkgs = with pkgs; [
        file
        jq
        fd
        ripgrep
        fzf
        zoxide
        poppler
        ffmpegthumbnailer
        unar
        imagemagick
        p7zip
      ];
    };

  flake.homeModules.yazi =
    { config, ... }:
    {
      home.file = {
        ".config/yazi".source =
          config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/yazi";
      };
    };

  flake.nixosModules.yazi =
    { pkgs, config, ... }:
    {
      imports = [ self.wrappers.yazi.install ];

      wrappers.yazi.configDir = "${config.preferences.dotsConfigPath}/yazi";

      # This is applied to this host with home-manager
      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.yazi
        ];
      };

      # The wrapper is installed through programs.yazi (which layers the plugins on top),
      # so wrappers.yazi.enable stays off to avoid installing it twice.
      programs.yazi = {
        enable = true;
        package = config.wrappers.yazi.wrapper;
        plugins = with pkgs.yaziPlugins; {
          inherit git;
          inherit starship;
          inherit ouch;
          inherit sudo;
          inherit drag;
          inherit mount;
          inherit gvfs;
          inherit sshfs;
          inherit bookmarks;
          inherit split-tabs;
        };

        # theme = fromTOML (builtins.readFile ./theme.toml);
      };
    };
}
