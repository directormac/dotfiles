{ inputs, ... }: {

  perSystem = { pkgs, ... }: {

    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        git
        vim
        yazi

        nixfmt
      ];
    };

  };
}
