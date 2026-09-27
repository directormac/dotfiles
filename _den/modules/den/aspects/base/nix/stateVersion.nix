{
  den.aspects.base.nix.stateVersion = {
    nixos = {
      system.stateVersion = "26.11";
    };

    homeManager = {
      home.stateVersion = "26.11";
    };
  };
}
