{ self, ... }:
{
  flake.homeModules.firefox =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      common = import ./_common { inherit pkgs lib; };
    in
    {
      stylix.targets.firefox = {
        enable = true;
        profileNames = [ "default" ];
      };

      programs.firefox = {
        enable = true;
        nativeMessagingHosts = common.nativeMessagingHosts;

        policies = common.policies // {
          # Full ephemeral sanitization on exit
          SanitizeOnShutdown = {
            Cache = true;
            Cookies = true;
            Downloads = true;
            FormData = true;
            History = true;
            Sessions = true;
            SiteSettings = true;
            Locked = true;
          };
          DisableFormHistory = true;
          PasswordManagerEnabled = false;
          OfferToSaveLogins = false;
          OfferToSaveLoginsDefault = false;
        };

        profiles.default = {
          isDefault = true;
          settings = {
            # Zero-history / ephemeral browsing settings
            "privacy.history.custom" = true;
            "privacy.sanitize.sanitizeOnShutdown" = true;
            "privacy.clearOnShutdown.cache" = true;
            "privacy.clearOnShutdown.cookies" = true;
            "privacy.clearOnShutdown.downloads" = true;
            "privacy.clearOnShutdown.formdata" = true;
            "privacy.clearOnShutdown.history" = true;
            "privacy.clearOnShutdown.offlineApps" = true;
            "privacy.clearOnShutdown.sessions" = true;
            "privacy.clearOnShutdown.siteSettings" = true;

            "browser.formfill.enable" = false;
            "places.history.enabled" = false;
            "browser.cache.disk.enable" = false;
            "browser.cache.memory.enable" = true;
            "browser.sessionstore.resume_from_crash" = false;
            "browser.sessionstore.max_resumed_crashes" = 0;
            "browser.sessionstore.privacy_level" = 2;

            "extensions.allowPrivateBrowsingByDefault" = true;
          };

          extensions = {
            packages = common.extensions.packages;
            settings = { };
          };

          search = common.search;

          userChrome = ''
            :root {
              --tab-border-radius: 0px !important;
              --border-radius-small: 0px !important;
              --border-radius-medium: 0px !important;
            }
          '';
        };
      };
    };
}
