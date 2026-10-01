{
  flake.homeModules.chromium = { pkgs, ... }: 
  let
    sharedArgs = [
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
    ];
  in {
    programs.chromium = {
      enable = true;
      package = pkgs.chromium;
      commandLineArgs = sharedArgs;
    };
    
    programs.google-chrome = {
      enable = true;
      commandLineArgs = sharedArgs;
    };
  };

  flake.nixosModules.chromium = { pkgs, ... }: 
  let
    sharedExtensions = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "leohhkagdnmgbpfbnflhjmnpcjpcjmgm" # Vimium New Tab Page
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      "ficfmibkjjnpogdcfhfokmihanoldbfe" # File Icons for GitHub and GitLab
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
    ];
    sharedExtraOpts = {
      ExtensionSettings = {
        "ddkjiahejlhfcafbddmgiahcphecmpfh" = { incognito = "allowed"; };
        "dbepggeogbaibhgnhhndojpepiihcmeb" = { incognito = "allowed"; };
        "leohhkagdnmgbpfbnflhjmnpcjpcjmgm" = { incognito = "allowed"; };
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" = { incognito = "allowed"; };
        "ficfmibkjjnpogdcfhfokmihanoldbfe" = { incognito = "allowed"; };
        "nngceckbapebfimnlniiiahkandclblb" = { incognito = "allowed"; };
        "mnjggcdmjocbbbhaepdhchncahnbgone" = { incognito = "allowed"; };
      };
      "RestoreOnStartup" = 1;
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      "PasswordManagerEnabled" = false;
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [
        "en-US"
      ];

      "DnsOverHttpsMode" = "secure";
      "DnsOverHttpsTemplates" = "https://cloudflare-dns.com/dns-query";
    };
  in {
    programs.chromium = {
      enable = true;

      extensions = sharedExtensions;

      defaultSearchProviderEnabled = true;
      defaultSearchProviderSearchURL = "https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
      defaultSearchProviderSuggestURL = "https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}";

      extraOpts = sharedExtraOpts;
    };

    environment.systemPackages = with pkgs; [
      chromium
      google-chrome
    ];

  };
}
