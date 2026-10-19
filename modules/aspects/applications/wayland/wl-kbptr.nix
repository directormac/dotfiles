# Wl-kbptr Keyboard Pointer Navigation Leaf Aspect
{
  lib,
  self,
  ...
}:
{
  den.aspects.applications.wayland.wl-kbptr = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.wlrctl
        ];

        imports = lib.optional (self ? wrappers && self.wrappers ? wl-kbptr) self.wrappers.wl-kbptr.install;
      };

    homeManager =
      { config, ... }:
      {
        imports = lib.optional (self ? wrappers && self.wrappers ? wl-kbptr) self.wrappers.wl-kbptr.install;
        wrappers.wl-kbptr.enable = true;
        xdg.configFile."wl-kbptr/config".source = config.lib.dots.link "wl-kbptr/config";
      };
  };

  flake.wrappers.wl-kbptr =
    {
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.wl-kbptr ];
      config.flags."--config" = lib.mkForce null;
      config.runtimePkgs = with pkgs; [ wlrctl ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.wl-kbptr-dev = lib.mkIf (self ? wrappers && self.wrappers ? wl-kbptr) (
        (self.wrappers.wl-kbptr.apply { }).wrap { inherit pkgs; }
      );
    };
}
