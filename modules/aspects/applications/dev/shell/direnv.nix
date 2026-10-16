# Direnv & Direnv-Instant Aspect
{
  lib,
  inputs,
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
          settings = {
            debug_log = "/tmp/direnv-instant.log";
            mux_delay = 2;
            use_cache = true;
          };

          enable = true;
        };

        xdg.configFile."direnv/direnv.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/direnv/direnv.toml";
      };

    persistHome.directories = [
      ".local/share/direnv"
    ];
  };
}
