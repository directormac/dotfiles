{ inputs, ... }: {
  flake.homeModules.doom-emacs = { pkgs, ... }: {
    imports = [ inputs.nix-doom-emacs-unstraightened.homeModule ];

    # xdg.configFile."doom.d" = {
    #   source = ../../../config/doom.d;
    #   recursive = true;
    # };

    programs.doom-emacs = {
      enable = true;
      provideEmacs = true;
    };

  };
}
