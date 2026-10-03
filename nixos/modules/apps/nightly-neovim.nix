{ inputs, self, ... }: {
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.nnvim =
        let
          nightly-neovim = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        pkgs.writeShellScriptBin "nnvim" ''
          # exec env NVIM_APPNAME=nvim ${nightly-neovim}/bin/nvim "$@"
          exec ${nightly-neovim}/bin/nvim "$@"
        '';
    };

  flake.nixosModules.nightly-neovim = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.nnvim
    ];
  };
}
