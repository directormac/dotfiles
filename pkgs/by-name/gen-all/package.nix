{
  coreutils,
  git,
  nix,
  writeShellApplication,
}:
writeShellApplication {
  name = "gen-all";

  runtimeInputs = [
    coreutils
    git
    nix
  ];

  text = ''
    REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/.dotfiles")"
    cd "$REPO_ROOT"

    echo "==> [1/3] Synchronizing flake.nix (write-flake)..."
    nix run .#write-flake

    echo "==> [2/3] Generating repository documentation & configs (write-files)..."
    nix run .#write-files

    echo "==> [3/3] Updating and validating cheatsheets (update-cheatsheets)..."
    nix run .#update-cheatsheets

    echo "==> All generator pipelines completed successfully."
  '';

  meta.description = "Run all repository generators: write-flake, write-files, and update-cheatsheets";
}
