{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.nh = inputs.lwrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.nh;
      env = {
        "NH_FLAKE" = "$HOME/nixconf";
      };
    };
  };
}
