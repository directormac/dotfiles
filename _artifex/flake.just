alias u := update
update *ARGS:
  nix flake update {{ARGS}}

alias c := check
[default]
check:
  nix flake check --impure

alias s := show
show:
  nix flake show --impure | grep -v omitted

alias w := write
write:
  nix run .#write-flake
  nix run .#write-files
