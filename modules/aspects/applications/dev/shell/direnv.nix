# Direnv & Direnv-Instant Aspect
{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    direnv-instant.url = "github:Mic92/direnv-instant";
  };

  den.aspects.applications.dev.shell.direnv = {
    homeManager =
      {
        config,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        imports = lib.optionals (inputs ? direnv-instant) [
          inputs.direnv-instant.homeModules.direnv-instant
        ];

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        programs.direnv-instant = lib.mkIf (inputs ? direnv-instant) {
          enable = true;
          settings = {
            mux_delay = 2;
            use_cache = true;
            debug_log = "/tmp/direnv-instant.log";
          };
        };

        xdg.configFile."direnv/direnv.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/direnv/direnv.toml";
      };

    persistHome.directories = [
      ".local/share/direnv"
    ];
  };
}
