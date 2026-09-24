{inputs, ...}:{
    perSystem = { pkgs, ... }: {

      packages.default = pkgs.vim;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          vim
        ];
      };

    };
}
