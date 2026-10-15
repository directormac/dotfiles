# This file defines overlays
{ inputs, ... }: {
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: _prev: {
  };

  # Thread the gen-lsp flake source to pkgs-by-name so pkgs/by-name/gen-lsp-mcp
  # can take `gen-lsp-src` as a callPackage arg and build the mcp/ subdir
  # hermetically (from the locked gen-lsp input, not a re-export of its package).
  # gen-lsp-src = _final: _prev: {
  #   gen-lsp-src = inputs.gen-lsp;
  # };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
    };
  };
}
