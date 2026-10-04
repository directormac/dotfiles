{ pkgs }:
let
  rycee-firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
in
{
  packages = with rycee-firefox-addons; [
    bitwarden
    clearurls
    darkreader
    sponsorblock
    ublock-origin
    vimium
  ];

  settings = {
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
      "{446900e4-71c2-419f-a6a7-df9c091e268b}"
      "addon@darkreader.org"
    ];
    "unified-extensions-area" = [
      "uBlock0@raymondhill.net"
      "sponsorBlocker@ajay.app"
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}"
    ];
  };
}
