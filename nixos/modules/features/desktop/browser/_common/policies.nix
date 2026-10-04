# Shared Mozilla enterprise policies configuration
# References:
# https://mozilla.github.io/policy-templates/
# https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/policies-config.nix
let
  mkExtensionSettings = builtins.mapAttrs (
    _: pluginId: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      allowed_types = [
        "extension"
        "theme"
      ];
    }
  );
in
{
  ExtensionSettings =
    mkExtensionSettings {
      "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = "catppuccin-mocha-mauve-git";
      "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = "github-file-icons";
      "{934e4b4a-2961-47d1-b507-4a91ac962cc3}" = "volume-control-boost-volume";
    }
    // {
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        default_area = "navbar";
        private_browsing = true;
      };
      "addon@darkreader.org" = {
        default_area = "navbar";
        private_browsing = true;
      };
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
        private_browsing = true;
      };
      "uBlock0@raymondhill.net" = {
        private_browsing = true;
      };
      "sponsorBlocker@ajay.app" = {
        private_browsing = true;
      };
    };

  DontCheckDefaultBrowser = true;
  HardwareAcceleration = true;
  ManualAppUpdateOnly = true;
  NoDefaultBookmarks = false;
  OfferToSaveLogins = false;
  PasswordManagerEnabled = false;
  OfferToSaveLoginsDefault = false;

  PictureInPicture = {
    Enabled = true;
  };

  EncryptedMediaExtensions = {
    Enabled = true;
  };

  FirefoxHome = {
    Search = false;
    TopSites = false;
    SponsoredTopSites = false;
    Highlights = false;
    Pocket = false;
    SponsoredPocket = false;
    Snippets = false;
    Locked = false;
  };

  EnableTrackingProtection = {
    Value = true;
    Locked = false;
    Cryptomining = true;
    Fingerprinting = true;
  };

  # Reference: https://mozilla.github.io/policy-templates/#preferences
  Preferences = {
    "browser.tabs.warnOnClose" = {
      Value = false;
    };
  };
}
