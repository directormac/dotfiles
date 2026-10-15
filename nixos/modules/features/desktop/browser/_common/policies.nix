# Shared Mozilla enterprise policies configuration
# References:
# https://mozilla.github.io/policy-templates/
# https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/policies-config.nix
{
  ExtensionSettings = {
    "{57e8684d-5ae8-47d6-93c9-f870ef0e40a3}" = {
      default_area = "navbar";
      private_browsing = true;
    };
    "addon@darkreader.org" = {
      default_area = "navbar";
      private_browsing = true;
    };
    "{3c078156-979c-498b-8990-85f7987dd929}" = {
      default_area = "navbar";
      private_browsing = true;
    };
    "uBlock0@raymondhill.net" = {
      default_area = "menupanel";
      private_browsing = true;
    };
    "sponsorBlocker@ajay.app" = {
      default_area = "menupanel";
      private_browsing = true;
    };
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
      default_area = "navbar";
      private_browsing = true;
    };
    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
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

  # 3rd-party Extension Policies
  "3rdparty".Extensions."uBlock0@raymondhill.net" = {
    toAdd = {
      trustedSiteDirectives = [
        "github.com"
      ];
    };
  };
}
