# Things to dooo on the road

## Rules

1. Keep the `config` directory agnostic of operating system.
2. As much as possible it should be the source of truth for configurations a.k.a dotfiles

- [ ] Implement [den](https://den.denful.dev) framework

  Start [here](https://den.denful.dev/tutorials/flake-parts-modules/#initialize)

  backup current `flake.nix` and remove `flake.lock`.

  ```sh
  mv flake.nix flake.nix.bak && rm flake.lock
  ```

  ```sh
  nix flake init -t github:denful/den#flake-parts-modules
  ```

  Directory structure:

  ```txt
  flake.nix
  modules/
    den.nix # Hosts, aspects using the classes, and pipeline wiring.
    perSystem-from-hosts.nix # Reads flake-parts classes from each host.
    pkgs-by-name.nix # Wires drupol/pkgs-by-name-for-flake-parts.
    classes/
    packages.nix # perSystem.packages.
    devshell.nix # numtide/devshell.
    treefmt.nix # numtide/treefmt-nix.
    files.nix # sini/files.
    nix-unit.nix # nix-community/nix-unit.
  packages/
    hola.nix
  ```

  Removing `packages/hola.nix` and `README.md`, i dont know the purpose of the packages yet maybe its for wrappers??? we will know soon!!

  before we continue lets be a responsible dev and lets integrate the tools along the way

  Language server and formatter add it through your ide or nix way, use mise if you are not using nix xD

  `nix profile add github:nix-community/nixd`

  `nix profile add github:kamadorueda/alejandra`

  or use mason

  `:MasonInstall alejandra`
  `:MasonToolsInstall nixd` you might need to use [this](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)
  `:MasonInstall statix`

  or mise `mise install cargo:alejandra`

  add some troubleshooting capabilities
  [read](https://den.denful.dev/guides/debug/) here so we need `just` but its not on the template we chose.
  so lets put another one! but backup things first xD

```sh
mv flake.nix flake.nix.parts.bak && mv modules/den.nix den.nix.parts.bak
nix flake init -t github:denful/den#example
rm flake.lock README.md .github/workflows/ci.yml
```

Now its looking `dendritic`! time to remove boilerplates!!

```txt
 .
├──  config -> dotfilessss
├──  docs
│   └──  ROADMAP.md
├──  lib
│   ├──  empty.nix
│   ├──  parts.nix
│   └──  theme.nix
├──  modules
│   ├──  classes
│   ├──  perSystem-from-hosts.nix
│   └──  pkgs-by-name.nix
├──  nixos -> old directory ignore
├──  packages
│   └──  .gitkeep
├──  wrapped -> old directory ignore
├──  .editorconfig
├──  .gitignore
├── 󰁯 den.nix.parts.bak
├── 󰁯 flake.nix.bak
├── 󰁯 flake.nix.parts.bak
└──  statix.toml
```

1. Use [import-tree](https://github.com/denful/import-tree) so we dont need to import manually
2. Use [flake-file](https://github.com/denful/flake-file) to generate `flake.nix`
3. Use [flake-parts](https://flake.parts/getting-started.html) cuz modulessss.
