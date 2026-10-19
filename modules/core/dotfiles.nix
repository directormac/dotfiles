# Live dotfiles: one definition of where `config/` lives and how aspects link into it.
#
# Aspects never spell the path themselves. They call the Home Manager helpers
# defined here:
#
#   xdg.configFile."kitty".source = config.lib.dots.link "kitty";   # out-of-store symlink
#   exec ${config.lib.dots.path "ghostty/shader.sh"} "$@"          # plain absolute path
#
# The root comes from `user.dotsConfigPath` (see `modules/core/settings.nix`),
# which follows `$DOTFILES_ROOT` when the configuration is evaluated with
# `--impure` (`rebuild-switch` exports it from the current git worktree) and
# otherwise falls back to `/home/<user>/.dotfiles/config`.
{ den, ... }:
{
  den.aspects.core.dotfiles.homeManager =
    {
      config,
      lib,
      user,
      ...
    }:
    {
      options.dots.configPath = lib.mkOption {
        default = user.dotsConfigPath;
        description = "Absolute path of the live `config/` directory that out-of-store symlinks point at.";
        type = lib.types.str;
      };

      config.lib.dots = {
        # Out-of-store symlink to `<configPath>/<relative>`; the target stays live-editable.
        link = relative: config.lib.file.mkOutOfStoreSymlink "${config.dots.configPath}/${relative}";
        # Absolute path of `<configPath>/<relative>` for scripts and command lines.
        path = relative: "${config.dots.configPath}/${relative}";
      };
    };

  den.schema.user.includes = [ den.aspects.core.dotfiles ];
}
