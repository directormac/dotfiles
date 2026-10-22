# Shared Mozilla enterprise policies configuration
# References:
# https://mozilla.github.io/policy-templates/
# https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/policies-config.nix
{
  # 3rd-party Extension Policies
  "3rdparty".Extensions."uBlock0@raymondhill.net" = {
    toAdd = {
      trustedSiteDirectives = [
        "github.com"
      ];
    };
  };

  DontCheckDefaultBrowser = true;

  EnableTrackingProtection = {
    Cryptomining = true;
    Fingerprinting = true;
    Locked = false;
    Value = true;
  };

  EncryptedMediaExtensions = {
    Enabled = true;
  };

  ExtensionSettings = {
    "addon@darkreader.org" = {
      default_area = "navbar";
      private_browsing = true;
    };

    "sponsorBlocker@ajay.app" = {
      default_area = "menupanel";
      private_browsing = true;
    };

    "uBlock0@raymondhill.net" = {
      default_area = "menupanel";
      private_browsing = true;
    };

    "{3c078156-979c-498b-8990-85f7987dd929}" = {
      default_area = "navbar";
      private_browsing = true;
    };

    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
      default_area = "navbar";
      private_browsing = true;
    };

    "{57e8684d-5ae8-47d6-93c9-f870ef0e40a3}" = {
      default_area = "navbar";
      private_browsing = true;
    };

    "vimium-c@gdh1995.cn" = {
      private_browsing = true;
    };
  };

  FirefoxHome = {
    Highlights = false;
    Locked = false;
    Pocket = false;
    Search = false;
    Snippets = false;
    SponsoredPocket = false;
    SponsoredTopSites = false;
    TopSites = false;
  };

  HardwareAcceleration = true;
  ManualAppUpdateOnly = true;
  NoDefaultBookmarks = false;
  OfferToSaveLogins = false;
  OfferToSaveLoginsDefault = false;
  PasswordManagerEnabled = false;

  PictureInPicture = {
    Enabled = true;
  };

  # Reference: https://mozilla.github.io/policy-templates/#preferences
  Preferences = {
    "browser.tabs.warnOnClose" = {
      Value = false;
    };
    "browser.tabs.insertAfterCurrent" = {
      Value = false;
    };
    "browser.tabs.insertRelatedAfterCurrent" = {
      Value = false;
    };
  };
}
