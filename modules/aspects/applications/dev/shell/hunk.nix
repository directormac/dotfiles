# Hunk - https://github.com/modem-dev/hunk
# https://www.hunk.dev/
{
  den.aspects.applications.dev.shell.hunk = {
    homeManager =
      {
        pkgs,
        # config,
        # user,
        ...
      }:
      # let
      #   dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      # in
      {
        home.packages = with pkgs; [
          hunk
        ];

        # xdg.configFile."hunk/config.toml".source =
        #   config.lib.file.mkOutOfStoreSymlink "${dotsPath}/hunk/config.toml";

        xdg.configFile."hunk/config.toml".text =
          # toml
          ''
            theme = "terminal"
            mode = "auto"
            line_numbers = true
            wrap_lines = false
          '';

      };

    persistHome.directories = [
      ".local/state/hunk"
    ];
  };
}
