{
  self,
  ...
}:
{
  flake.wrappers.wl-kbptr =
    {
      config,
      lib,
      wlib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.wl-kbptr ];

      # The wrapper module always appends `--config=<generated.ini>`, and that
      # generated file is empty -- which shadows the live XDG config at
      # ~/.config/wl-kbptr/config (the mkOutOfStoreSymlink in the home module).
      # Drop the flag so the dotfile is actually read. Per-invocation `-o`
      # overrides from the Hyprland bindings still take precedence over the file.
      config.flags."--config" = lib.mkForce null;

      config.runtimePkgs = with pkgs; [ wlrctl ];

    };

  # ---------------------------------------------------------------------------
  # Install modules. flake-parts gives each `flake.wrappers.<name>` a `.install`.
  # ---------------------------------------------------------------------------
  flake.homeModules.wl-kbptr = { config, ... }: {
    imports = [ self.wrappers.wl-kbptr.install ];

    wrappers.wl-kbptr.enable = true;

    xdg.configFile."wl-kbptr/config".source =
      config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/wl-kbptr/config";

  };

  flake.nixosModules.wl-kbptr = { config, pkgs, ... }: {
    imports = [ self.wrappers.wl-kbptr.install ];

    environment.systemPackages = [ pkgs.wlrctl ];

    home-manager.users.${config.preferences.user.name} = {
      imports = [ self.homeModules.wl-kbptr ];
    };

  };

  perSystem = { pkgs, ... }: {
    packages.wl-kbptr-dev = (self.wrappers.wl-kbptr.apply { }).wrap { inherit pkgs; };
  };
}
