{ self, ... }: {
  perSystem =
    { pkgs, ... }:
    {
      packages.tmux = pkgs.callPackage ../../pkgs/tmux.nix { };
    };
}
