{
  lib,
  den,
  inputs,
  ...
}:
{

  den.default.includes = [
    # System
    # den.batteries.define-user
    # Creates OS-level user accounts (users.users.<name>) with isNormalUser and home directory.
    # Also sets home.username and home.homeDirectory for Home Manager.
    # Works on NixOS, Darwin, and standalone Home Manager.
    # [define-user.nix](https://github.com/denful/den/blob/main/modules/aspects/batteries/define-user.nix)
    den.batteries.define-user

    # Sets the system hostname from den.hosts.<name>.hostName.
    # Works on NixOS and Darwin.
    # [hostname.nix](https://github.com/denful/den/blob/main/modules/aspects/batteries/define-user.nix)
    den.batteries.hostname

    # Provides the `flake-parts` `inputs'` (the flake's `inputs` with system pre-selected)
    # as a top-level module argument.
    # This allows modules to access per-system flake outputs without needing
    # `pkgs.stdenv.hostPlatform.system`.
    # ## Usage
    # **Global (Recommended):**
    # Apply to all hosts, users, and homes.
    #     den.default.includes = [ den.inputs' ];
    # **Specific:**
    # Apply only to a specific host, user, or home aspect.
    #     den.aspects.my-laptop.includes = [ den.inputs' ];
    #     den.aspects.alice.includes = [ den.inputs' ];
    # **Note:** This aspect is contextual. When included in a `host` aspect, it
    # configures `inputs'` for the host's OS. When included in a `user` or `home`
    # aspect, it configures `inputs'` for the corresponding Home Manager configuration.
    den.batteries.inputs'

    # Provides the `flake-parts` `self'` (the flake's `self` with system pre-selected) as a top-level module argument.
    # This allows modules to access per-system flake outputs without needing
    # `pkgs.stdenv.hostPlatform.system`.
    # ## Usage
    # **Global (Recommended):**
    # Apply to all hosts, users, and homes.
    #     den.default.includes = [ den.self' ];
    # **Specific:**
    # Apply only to a specific host, user, or home aspect.
    #     den.aspects.my-laptop.includes = [ den.self' ];
    #     den.aspects.alice.includes = [ den.self' ];
    # **Note:** This aspect is contextual. When included in a `host` aspect, it
    # configures `self'` for the host's OS. When included in a `user` or `home`
    # aspect, it configures `self'` for the corresponding Home Manager configuration.
    den.batteries.self'
    den.aspects.core.nixpkgs
  ];

  den.default.nixos.boot.zfs.forceImportRoot = lib.mkDefault false;
  den.default.nixos.system.stateVersion = "26.05";
  den.default.nixos.nixpkgs.config.allowUnfree = lib.mkDefault true;
  den.default.nixos.nixpkgs.overlays = [ inputs.self.overlays.default ];
  den.default.nixos.home-manager.useGlobalPkgs = lib.mkDefault true;
  den.default.nixos.home-manager.useUserPackages = lib.mkDefault true;

  # Enable Home Manager by default for all declared users
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default.homeManager.home.stateVersion = "26.05";
}
