# Developer Tools Aspect: Direnv, Mise, Go, Rust, Node, Bun
{ core, ... }:
{
  core.devtools = {
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
          nodejs_26
          bun
          cargo
          rustc
          deno
          mise
        ];

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        programs.go = {
          enable = true;

          env = {
            GOPATH = [
              "${config.home.homeDirectory}/.config/go"
            ];
          };
        };

        programs.mise = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        xdg.configFile = {
          "direnv/direnv.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/direnv/direnv.toml";
          "mise/.miserc.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mise/.miserc.toml";
          "mise/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mise/config.toml";
        };
      };

    persistHome.directories = [
      ".local/share/direnv"
      ".local/share/mise"
      ".config/go"
    ];
  };

  den.aspects.artifex.includes = [
    core.devtools
  ];
}
