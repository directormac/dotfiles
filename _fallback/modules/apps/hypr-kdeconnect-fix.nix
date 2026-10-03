{ self, ... }: {
  perSystem =
    { pkgs, ... }:
    {
      packages.hypr-kdeconnect-fix = pkgs.callPackage ../../pkgs/hypr-kdeconnect-fix.nix { };
    };
}
