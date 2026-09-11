# Development shell providing tools for working with this configuration:
#   - age:  encrypt/decrypt files with age keys
#   - just: task runner (see Justfile)
#   - sops: edit and manage the encrypted secrets.yaml
# Enter with `nix develop` or via direnv.
{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        age
        just
        sops
      ];
    };
  };
}
