{ lib, inputs, ... }:
{
  flake-file.inputs = {
    rust-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:oxalica/rust-overlay";
    };
  };

  den.aspects.applications.dev.lang.rust = {
    homeManager =
      { pkgs, ... }:
      {
        # The `default` profile already includes clippy + rustfmt;
        # rust-analyzer as an extension stays version-matched to the toolchain.
        home.packages = [
          (pkgs.rust-bin.stable.latest.default.override {
            extensions = [ "rust-analyzer" ];
          })
        ];

        # cargo install writes here; make those binaries usable globally
        home.sessionPath = [ "$HOME/.cargo/bin" ];
      };

    cacheHome.directories = [
      ".cargo"
      ".rustup"
    ];

    # Collected by core/nixpkgs.nix and applied via nixpkgs.overlays;
    # flows into Home Manager's pkgs too. Guarded per repo convention.
    nixpkgs-overlays =
      _:
      lib.optionals (inputs ? rust-overlay && inputs.rust-overlay ? overlays) [
        inputs.rust-overlay.overlays.default
      ];
  };
}
