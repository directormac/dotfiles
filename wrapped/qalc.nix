{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.qalc = inputs.lwrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.libqalculate;
      args = [
        "-s"
        "autocalc"
        "-s"
        "decimal comma off"
      ];
    };
  };
}
