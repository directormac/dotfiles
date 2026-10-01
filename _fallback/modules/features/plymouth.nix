{
  flake.nixosModules.plymouth = { pkgs, ... }: {

    stylix.targets.plymouth = {
      enable = true;
    };

  };
}
