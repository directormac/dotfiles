host := `hostname`

alias b := build
build HOST=host *ARGS:
    @#nix build .#nixosConfigurations.{{HOST}}.config.system.build.toplevel {{ARGS}}
    nh os build --hostname {{HOST}}

alias bo := boot
boot HOST=host *ARGS:
    @#nixos-rebuild boot --flake .#{{HOST}} --target-host {{HOST}} --use-substitutes --sudo --ask-sudo-password
    nh os boot --hostname {{HOST}} --target-host {{HOST}} --use-substitutes {{ARGS}}

alias s := switch
[default]
switch HOST=host *ARGS:
    @#nixos-rebuild switch --flake .#{{HOST}} --target-host {{HOST}} --use-substitutes --sudo --ask-sudo-password
    nh os switch --hostname {{HOST}} --target-host {{HOST}} --use-substitutes {{ARGS}}
