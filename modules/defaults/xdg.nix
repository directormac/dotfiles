# [home-environment](https://github.com/nix-community/home-manager/blob/master/modules/home-environment.nix)
# [home.sessionVarialbes]https://search.nixos.org/options?channel=unstable&query=sessionVariables&source=home_manager&type=options#show=home-manager-option%253Ahome.sessionVariables
{lib, ...}: {
  den.default.homeManager.home.sessionVariables = rec {
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";

    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    GNUPGHOME = lib.mkForce "${XDG_DATA_HOME}/gnupg";
  };
}
