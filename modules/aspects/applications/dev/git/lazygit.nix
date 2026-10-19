# Lazygit TUI Git Client Aspect
{
  den.aspects.applications.dev.git.lazygit = {
    homeManager =
      { config, ... }:
      {
        programs.lazygit.enable = true;
        xdg.configFile."lazygit".source = config.lib.dots.link "lazygit";
      };

    persistHome.directories = [
      ".local/state/lazygit"
    ];
  };
}
