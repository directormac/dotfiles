{
  lib,
  core,
  den,
  ...
}:
{
  den.aspects.mac = {
    # Including other aspects.
    # For small, private one-shot aspects, use let-bindings like here.
    # for more complex or re-usable ones, define on their own modules,
    # as part of any aspect-subtree.
    includes =
      let
        # not required, showcasing angle-brackets syntax.
        # deadnix: skip
        inherit (den.lib) __findFile;
      in
      with core;
      [
        # Projects user-relevant classes (like homeManager) from the host’s aspect tree onto users who opt in.
        # Any homeManager key defined in the host aspect is forwarded to the user’s home-manager evaluation.
        # [host-aspects.nix](https://github.com/denful/den/blob/main/modules/aspects/batteries/host-aspects.nix)
        den.batteries.host-aspects

        # Sets the user’s login shell at both OS and Home Manager levels.
        # Enables programs.<shell>.enable and
        # sets users.users.<name>.shell.
        # [user-shell.nix](https://github.com/denful/den/blob/main/modules/aspects/batteries/user-shell.nix)
        (den.batteries.user-shell "zsh")

        # { nixos.security.sudo.wheelNeedsPassword = false; }

        # Desktop/GUI-only aspects (editors, browsers, media, ...).
        ({ host }: { includes = lib.optionals host.isWorkstation [ workstation ]; })
      ]
      ++ [
        # from local bindings.
        # customEmacs
        # from the `eg` namespace.
        # eg.autologin
        # den included batteries that provide common configs.

        # Marks a user as the primary (admin-level) user.
        # On NixOS, adds wheel and networkmanager groups.
        # On Darwin, sets system.primaryUser.
        # On WSL, sets defaultUser.
        den.batteries.primary-user

        core.set-user

        # (den.batteries.user-shell "dash") # default user shell # Cannot be used for `dash`.
      ];

    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.htop ];
    };

    # user can provide NixOS configurations
    # to any host it is included on
    provides.to-hosts.nixos = _: { };
  };
}
