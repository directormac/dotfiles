_: {
  perSystem = {
    files.file = {
      "README.md" = {
        text = /* markdown */ ''

          # Quicklinkgs

          [NixOSWiki](https://nixos.wiki/wiki/Main_Page)
          [NixOSCheatsheet](https://nixos.wiki/wiki/Cheatsheet)

          [nixpkgs search](https://search.nixos.org/packages?channel=unstable)
          [nixpkgs options](https://search.nixos.org/options?channel=unstable&type=options)

          [flake-parts](https://flake.parts/options/flake-parts.html)

          [devenv-flake-parts](https://devenv.sh/guides/using-with-flake-parts/)
          [secretspect](https://secretspec.dev/reference/configuration/)

          # Getting Started Guide

          Steps you can follow after cloning this template:

          - Be sure to read the [den documentation](https://den.denful.dev)

          - Update den input.

          ```console
          nix flake update den
          ```

          - Edit [modules/hosts.nix](modules/hosts.nix)

          - Build

          ```console
          # default action is build
          nix run .#igloo

          # pass any other nh action
          nix run .#igloo -- switch
          ```

          - Run the VM

          We recommend to use a VM develop cycle so you can play with the system before applying to your hardware.

          See [modules/vm.nix](modules/vm.nix)

          ```console
          nix run .#vm
          ```

          Useful if using outisde of nixos

          ```sh
          nix profile add github:vic/nix-versions

          nix-versions hyprland
          ```


          ## Requirements

          1.[nix](https://nix.dev/install-nix)
          2.[devenv](https://devenv.sh/getting-started/)
          3.[nix-direnv](https://github.com/nix-community/nix-direnv)

          ```sh
          sh <(curl -L https://nixos.org/nix/install) --daemon
          nix profile add nixpkgs#devenv
          nix profile add nixpkgs#nix-direnv
          ```

          Then run `direnv allow` if you havent yet.


          ### Formatting

          1. `treefmt-nix` which is wired up at `modules/flake/formatter.nix`
          2. `pedantix` a configurable formatter for nix
            integrated with `treefmt-nix` setup is also at `formatter.nix`
            [Configuration](https://swarsel.github.io/pedantix/configuration.html) at `pedantix.toml`.
          3. `nixfmt` for nix files. `stylua` for lua.

        '';
      };
    };
  };
}
