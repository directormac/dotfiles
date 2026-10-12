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
      imports = [ wlib.wrapperModules.yazi ];

      config.plugins = with pkgs.yaziPlugins; {
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

      config.settings = {
        theme = {
          indicator = {
            padding = {
              open = "█";
              close = "█";
            };
            parent = {
              fg = "#1e1e2e";
              bg = "#cdd6f4";
            };
            current = {
              fg = "#1e1e2e";
              bg = "#89b4fa";
            };
            preview = {
              fg = "#1e1e2e";
              bg = "#cdd6f4";
            };
          };

        };
      };

      # config.binName = lib.mkDefault "yazi";
      # config.package = lib.mkForce pkgs.yazi-unwrapped;

      # config.envDefault.YAZI_CONFIG_HOME = "${config.configDir}";
    };

  flake.homeModules.yazi =
    { config, ... }:
    {
      imports = [ self.wrappers.yazi.install ];

      wrappers.yazi.enable = true;

      # home.file = {
      #   ".config/yazi".source =
      #     config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/yazi";
      # };
    };

  flake.nixosModules.yazi =
    { pkgs, config, ... }:
    {
      imports = [ self.wrappers.yazi.install ];

      home-manager.users.${config.preferences.user.name} = {
        imports = [ self.homeModules.yazi ];
      };

    };

  perSystem =
    { pkgs, ... }:
    {
      packages.yazi-dev = (self.wrappers.yazi.apply { }).wrap { inherit pkgs; };
    };
}
