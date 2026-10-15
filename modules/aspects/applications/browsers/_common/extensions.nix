{ pkgs }:
let
  rycee-firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
  buildFirefoxXpiAddon = rycee-firefox-addons.buildFirefoxXpiAddon;

  # Helper to parse and normalize Vimium C JSON backup into storage.local schema
  vimiumCRaw = builtins.fromJSON (builtins.readFile ./vimium-c.json);
  normalizeVimiumVal = v: if builtins.isList v then builtins.concatStringsSep "\n" v else v;
  vimiumCSettings = builtins.mapAttrs (_: normalizeVimiumVal) (
    removeAttrs vimiumCRaw [
      "name"
      "@time"
      "time"
      "environment"
    ]
  );

in
{
  catppuccin-mocha-mauve = rycee-firefox-addons.catppuccin-mocha-mauve;

  customAddons = {
    volume-control-boost-volume = buildFirefoxXpiAddon {
      pname = "volume-control-boost-volume";
      version = "6.20";
      addonId = "{57e8684d-5ae8-47d6-93c9-f870ef0e40a3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/5098066/volume_control_boost_volume-6.20.xpi";
      sha256 = "sha256-mPRJmdW+VeoIOAZn8IMYw+VaX0VKZr4my9+NL/XyqRk=";
      meta = with pkgs.lib; {
        homepage = "https://github.com/Chaython/volumecontrol";
        description = "Adds a volume control for the current site, that can also boost the volume beyond the normal range.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "activeTab"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
  };

  rycee-firefox-addons = rycee-firefox-addons;

  vimiumCSettings = vimiumCSettings;

  packages = with rycee-firefox-addons; [
    bitwarden
    clearurls
    darkreader
    sponsorblock
    ublock-origin
    vimium
  ];

  settings = {
    # Dark Reader declarative configuration
    "addon@darkreader.org" = {
      force = true;
      settings = {
        schemeVersion = 2;
        enabled = true;
        enabledByDefault = true;
        enabledFor = [ ];
        disabledFor = [ "github.com" ];
        siteList = [ "github.com" ];
        syncSettings = false;
      };
    };

    # ClearURLs declarative configuration
    "{74145f27-f039-47ce-a470-a662b129930a}" = {
      force = true;
      settings = {
        badged_color = "#7b383a";
        badgedStatus = true;
        domainBlocking = false;
        eTagFiltering = true;
        hashURL = "https://rules2.clearurls.xyz/rules.minify.hash";
        historyListenerEnabled = true;
        localHostsSkipping = true;
        logLimit = 250;
        loggingStatus = true;
        pingBlocking = true;
        referralMarketing = true;
        ruleURL = "https://rules2.clearurls.xyz/data.minify.json";
        statisticsStatus = true;
      };
    };
  };

  extensionButtons = {
    "nav-bar" = [
      "{57e8684d-5ae8-47d6-93c9-f870ef0e40a3}" # Volume Control
      "addon@darkreader.org" # Dark Reader
      "{3c078156-979c-498b-8990-85f7987dd929}" # Sidebery
    ];
    "unified-extensions-area" = [
      "uBlock0@raymondhill.net" # uBlock Origin
      "sponsorBlocker@ajay.app" # SponsorBlock
      "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" # github-file-icons
      "{74145f27-f039-47ce-a470-a662b129930a}" # ClearURLs
      "vimium-c@gdh1995.cn" # Vimium C
      "{7efbd09d-90ad-47fa-b91a-08c472bdf566}" # fake-filler
      "{84c8edb0-65ca-43a5-bc53-0e80f41486e1}" # tweaks-for-youtube
    ];
  };
}
