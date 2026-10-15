# Mise & Pitchfork Runtime Manager Aspect
{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    mise-nix.url = "github:wadackel/mise-nix";
  };

  den.aspects.applications.dev.shell.mise = {
    nixpkgs-overlays =
      _:
      lib.optionals (inputs ? mise-nix && inputs.mise-nix ? overlays) [
        inputs.mise-nix.overlays.default
      ];

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

    persistHome.directories = [
      ".local/share/mise"
    ];
  };
}
