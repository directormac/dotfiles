{
  flake.homeModules.chromium = { pkgs, ... }: {
    programs.chromium = {
      enable = true;
      package = pkgs.chromium;
      commandLineArgs = [
        "--restore-last-session=true"
        "--enable-features=AcceleratedVideoDecodeLinuxGL"
        "--enable-logging=stderr"
        "--disable-sync-preferences"
        "--extension-mime-request-handling=always-prompt-for-install"
        "--no-default-browser-check"
        "--enable-zero-copy"
        "--ignore-gpu-blocklist"
        "--enable-parallel-downloading"
        "--disable-session-crashed-bubble"
        # "--use-mock-keychain"
      ];
      # extensions =
      #   let
      #     ids = [
      #       "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      #       "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      #       "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      #       "ficfmibkjjnpogdcfhfokmihanoldbfe" # File Icons for GitHub and GitLab
      #       # "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      #       # "dffbjiomnajbmlhjelpipfldgkijdemn" # URL Cleaner
      #     ];
      #   in
      #   map (id: { inherit id; }) ids;
    };
  };

  flake.nixosModules.chromium = { pkgs, ... }: {
    # https://github.com/luisnquin/nixos-config/blob/9f641d16c74cf9a90fdf5b654376a1d6c8cc1f86/system/modules/programs/browser/chromium.nix
    # https://search.nixos.org/options?channel=unstable&query=programs.chromium&type=options
    programs.chromium = {
      enable = true;

      extensions = [
        "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "ficfmibkjjnpogdcfhfokmihanoldbfe" # File Icons for GitHub and GitLab
      ];

      defaultSearchProviderEnabled = true;
      defaultSearchProviderSearchURL = "https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
      defaultSearchProviderSuggestURL = "https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}";

      # https://cloud.google.com/docs/chrome-enterprise/policies/
      extraOpts = {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [
          "en-US"
        ];

        "DnsOverHttpsMode" = "secure";
        "DnsOverHttpsTemplates" = "https://cloudflare-dns.com/dns-query";

        # "ManagedBookmarks" = [
        # ];
      };
    };

    environment.systemPackages = with pkgs; [
      chromium
    ];

  };
}
