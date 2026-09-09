{ inputs, ... }: {
  flake.nixosModules.nix = { pkgs, ... }: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];
    programs = {
      nix-index-database.comma.enable = true;

      # direnv = {
      #   enable = true;
      #   silent = false;
      #   loadInNixShell = true;
      #   direnvrcExtra = "";
      #   nix-direnv = {
      #     enable = true;
      #   };
      # };
      nix-ld.enable = true;
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      # Nix tooling
      nil
      nixd
      statix
      alejandra
      nixfmt
      manix
      nix-inspect
      devenv
    ];

    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
