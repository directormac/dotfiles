{ den, ... }: {
  den.default = {
    nixos.system.stateVersion = "26.11";
    homeManager.home.stateVersion = "26.11";
  };

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

    # Recursively imports non-dendritic .nix files depending on their Nix configuration `class`.
    # This can be used to help migrating from huge existing setups.
    # ```
    #   # this is at <repo>/modules/non-dendritic.nix
    #   den.aspects.my-laptop.includes = [
    #     (den.import-tree.host ../non-dendritic)
    #   ]
    # ```
    # With following structure, it will automatically load modules depending on their class.
    # ```
    #     <repo>/
    #       modules/
    #         non-dendritic.nix # configures this aspect
    #       non-dendritic/ # name is just an example here
    #         hosts/
    #           my-laptop/
    #             _nixos/          # a directory for `nixos` class
    #               auto-generated-hardware.nix # any nixos module
    #             _darwin/
    #               foo.nix
    #             _homeManager/
    #               me.nix
    # ```
    # ## Requirements
    #   - inputs.import-tree
    # ## Usage
    #   this aspect can be included explicitly on any aspect:
    #       # example: will import ./disko/_nixos files automatically.
    #       den.aspects.my-disko.includes = [ (den.import-tree ./disko/) ];
    #   or it can be default imported per host/user/home:
    #       # load from ./hosts/<host>/_nixos
    #       den.default.includes = [ (den.import-tree.host ./hosts) ];
    #       # load from ./users/<user>/{_homeManager, _nixos}
    #       den.default.includes = [ (den.import-tree.user ./users) ];
    #       # load from ./homes/<home>/_homeManager
    #       den.default.includes = [ (den.import-tree.home ./homes) ];
    #   you are also free to create your own auto-imports layout following the implementation of these.
  ];
}
