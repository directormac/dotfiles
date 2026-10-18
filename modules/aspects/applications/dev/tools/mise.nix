# Mise & Pitchfork Runtime Manager Aspect
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    mise-nix.url = "github:wadackel/mise-nix";
  };

  den.aspects.applications.dev.tools.mise = {
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
          mise
          pitchfork
        ];

        programs.mise = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          mutableSettings = true;
        };

        xdg.configFile = {
          "mise/.miserc.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mise/.miserc.toml";
          "mise/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mise/config.toml";
        };
      };

    cacheHome.directories = [
      ".cache/mise"
      ".local/share/mise"
    ];

    nixpkgs-overlays =
      _:
      lib.optionals (inputs ? mise-nix && inputs.mise-nix ? overlays) [
        inputs.mise-nix.overlays.default
      ];

    persistHome.directories = [
      ".local/state/mise"
    ];
  };
}
