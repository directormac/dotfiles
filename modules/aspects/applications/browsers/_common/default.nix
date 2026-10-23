{
  pkgs,
}:
{
  autohideSidebarCss = builtins.readFile ./styles/autohide_sidebar.css;
  autohideToolboxCss = builtins.readFile ./styles/autohide_toolbox.css;

  # Script to configure extension command shortcuts (e.g. Sidebery toggle Ctrl+Alt+S)
  configureExtensionCommands =
    {
      profileDirs,
      commands ? {
        "_execute_sidebar_action" = "Ctrl+Alt+S";
      },
    }:
    let
      cmdsJson = builtins.toJSON commands;
      sideberyId = "{3c078156-979c-498b-8990-85f7987dd929}";
    in
    ''
      targetDirs=()
      for profileDir in ${builtins.concatStringsSep " " profileDirs}; do
        targetDirs+=("$HOME/$profileDir")
      done
      # Also discover any existing profile directories under common roots (handles randomized prefixes like *.default)
      for base in "$HOME/.mozilla/firefox" "$HOME/.config/mozilla/firefox" "$HOME/.librewolf" "$HOME/.config/librewolf"; do
        if [ -d "$base" ]; then
          for d in "$base"/*; do
            if [ -d "$d" ] && { [ -f "$d/prefs.js" ] || [ -f "$d/extension-settings.json" ] || [ -d "$d/extensions" ]; }; then
              targetDirs+=("$d")
            fi
          done
        fi
      done

      for fullDir in "''${targetDirs[@]}"; do
        [ -n "$fullDir" ] || continue
        mkdir -p "$fullDir"
        settingsFile="$fullDir/extension-settings.json"
        if [ ! -f "$settingsFile" ]; then
          echo '{"version":3,"commands":{},"prefs":{}}' > "$settingsFile"
        fi
        if ${pkgs.jq}/bin/jq empty "$settingsFile" 2>/dev/null; then
          UPDATED=$(${pkgs.jq}/bin/jq --argjson cmds '${cmdsJson}' --arg addon '${sideberyId}' '
            . as $orig |
            reduce ($cmds | to_entries[]) as $entry ($orig;
              .commands[$entry.key] = {
                initialValue: (.commands[$entry.key].initialValue // {}),
                precedenceList: [
                  {
                    id: $addon,
                    installDate: (.commands[$entry.key].precedenceList[0].installDate // (now * 1000 | floor)),
                    value: { shortcut: $entry.value },
                    enabled: true
                  }
                ]
              }
            )
          ' "$settingsFile")
          if [ -n "$UPDATED" ] && echo "$UPDATED" | ${pkgs.jq}/bin/jq empty 2>/dev/null; then
            echo "$UPDATED" > "$settingsFile"
          fi
        fi
      done
    '';

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
