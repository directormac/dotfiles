{
  pkgs,
}:
{
  autohideSidebarCss = builtins.readFile ./styles/autohide_sidebar.css;
  autohideToolboxCss = builtins.readFile ./styles/autohide_toolbox.css;
  extensions = import ./extensions.nix { inherit pkgs; };
  findbarCss = builtins.readFile ./styles/better-findbar.css;
  floatingFindbarCss = builtins.readFile ./styles/floating_findbar.css;
  nativeMessagingHosts = import ./native-hosts.nix { inherit pkgs; };
  policies = import ./policies.nix;
  search = import ./search.nix { inherit pkgs; };

  # Keep login sessions, cookies, and site storage intact across browser restarts and reboots,
  # and prevent Firefox Sync from propagating LibreWolf's clear-on-shutdown defaults.
  sessionSettings = {
    "browser.sessionstore.privacy_level" = 0;
    "browser.sessionstore.resume_from_crash" = true;
    "browser.startup.page" = 3;
    "browser.tabs.insertAfterCurrent" = false;
    "browser.tabs.insertRelatedAfterCurrent" = false;
    "privacy.clearOnShutdown.cookies" = false;
    "privacy.clearOnShutdown.offlineApps" = false;
    "privacy.clearOnShutdown.sessions" = false;
    "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
    "privacy.sanitize.sanitizeOnShutdown" = false;
    "services.sync.prefs.sync.privacy.clearOnShutdown.cookies" = false;
    "services.sync.prefs.sync.privacy.clearOnShutdown.offlineApps" = false;
    "services.sync.prefs.sync.privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
    "services.sync.prefs.sync.privacy.sanitize.sanitizeOnShutdown" = false;
  };
}
