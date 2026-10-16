# Devenv
{
  flake-file = {

    inputs = {
      devenv.url = "github:cachix/devenv";
      mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
      nix2container.url = "github:nlewo/nix2container";
    };

    nixConfig = {
      extra-substituters = [
        "https://devenv.cachix.org"
      ];

      extra-trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
  };

  den.aspects.applications.dev.tools.devenv = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.devenv
        ];

        nix.settings = {
          extra-substituters = [
            "https://devenv.cachix.org"
          ];

          extra-trusted-public-keys = [
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.devenv
        ];
      };

    # persistHome.directories = [
    #   ".local/share/devenv"
    # ];
  };
}
