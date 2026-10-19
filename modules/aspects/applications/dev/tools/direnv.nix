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

  den.aspects.applications.dev.tools.direnv = {
    homeManager =
      { config, ... }:
      {
        imports = lib.optionals (inputs ? direnv-instant) [
          inputs.direnv-instant.homeModules.direnv-instant
        ];

        programs.direnv = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };

        programs.direnv-instant = lib.mkIf (inputs ? direnv-instant) {
          enable = true;

          settings = {
            debug_log = "/tmp/direnv-instant.log";
            mux_delay = 4;
            use_cache = true;
          };
        };

        xdg.configFile."direnv/direnv.toml".source = config.lib.dots.link "direnv/direnv.toml";

      };

    cacheHome.directories = [
      ".local/share/direnv"
    ];
  };
}
