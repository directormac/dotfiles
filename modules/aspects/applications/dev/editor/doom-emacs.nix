# Doom Emacs Editor Aspect
{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    nix-doom-emacs-unstraightened = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:marienz/nix-doom-emacs-unstraightened";
    };
  };

  den.aspects.applications.dev.editor.doom-emacs = {
    homeManager =
      { lib, ... }:
      {
        imports = lib.optional (
          inputs ? nix-doom-emacs-unstraightened && inputs.nix-doom-emacs-unstraightened ? homeModule
        ) inputs.nix-doom-emacs-unstraightened.homeModule;

        programs.doom-emacs =
          lib.mkIf
            (inputs ? nix-doom-emacs-unstraightened && inputs.nix-doom-emacs-unstraightened ? homeModule)
            {
              enable = true;
              provideEmacs = true;
            };
      };
  };
}
