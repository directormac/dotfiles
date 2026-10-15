# Wl-kbptr Keyboard Pointer Navigation Leaf Aspect
{
  core,
  den,
  self,
  lib,
  ...
}:
{
  flake.wrappers.wl-kbptr =
    {
      lib,
      wlib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.wl-kbptr ];

      config.flags."--config" = lib.mkForce null;
      config.runtimePkgs = with pkgs; [ wlrctl ];
    };

  den.aspects.applications.wayland.wl-kbptr = {
    nixos =
      { pkgs, ... }:
      {
        imports = lib.optional (self ? wrappers && self.wrappers ? wl-kbptr) self.wrappers.wl-kbptr.install;

        environment.systemPackages = [
          pkgs.wlrctl
        ];
      };

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
        imports = lib.optional (self ? wrappers && self.wrappers ? wl-kbptr) self.wrappers.wl-kbptr.install;

        wrappers.wl-kbptr.enable = true;

        xdg.configFile."wl-kbptr/config".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/wl-kbptr/config";
      };
  };


  perSystem =
    { pkgs, ... }:
    {
      packages.wl-kbptr-dev = lib.mkIf (self ? wrappers && self.wrappers ? wl-kbptr) (
        (self.wrappers.wl-kbptr.apply { }).wrap { inherit pkgs; }
      );
    };
}
