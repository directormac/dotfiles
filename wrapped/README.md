# Wrapper Modules Guidelines

This directory contains configuration for wrapping programs using `nix-wrapper-modules` (from `nix-community`).

## 1. Library Consistency
We use `inputs.wrappers` (`nix-community/nix-wrapper-modules`) for all wrapper derivations.
Do not use `lwrappers` or mix different wrapper-manager frameworks, as they provide overlapping functionality.

## 2. Reusable Modules (Dogfooding)
When defining a module that you also want to use internally within the same flake, **do not import it via `self`** (e.g. `imports = [ self.wrappersModules.myApp ]`).
Relying on `self` for internal consumption can lead to infinite recursion and assumes the final consumer's flake has the same structure.

**Best Practice ("Factor it out"):**
```nix
{ inputs, ... }:
let
  myAppModule = { config, lib, ... }: {
    options = { /* ... */ };
    config = { /* ... */ };
  };
in {
  # 1. Export it for external use
  flake.wrappersModules.myApp = myAppModule;

  # 2. Use the local variable internally
  perSystem = { pkgs, ... }: {
    packages.myApp = (inputs.wrappers.wrapperModules.myApp.apply {
      inherit pkgs;
      imports = [ myAppModule ];
    }).wrapper;
  };
}
```

## 3. Do Not Hardcode `self` or `self'`
A reusable module should be pure. It should not reach into `self.theme` or `self'.packages` directly. If someone else imports your module, their `self` won't have those values.

**Instead, define options:**
```nix
options.theme = lib.mkOption {
  type = lib.types.attrsOf lib.types.str;
  default = {};
};
options.customPackage = lib.mkOption {
  type = lib.types.package;
};
```

**And pass them when applying:**
```nix
packages.myApp = (inputs.wrappers.wrapperModules.myApp.apply {
  inherit pkgs;
  imports = [ myAppModule ];
  
  # Pass them here in perSystem:
  theme = self.theme;
  customPackage = self'.packages.myApp;
}).wrapper;
```
