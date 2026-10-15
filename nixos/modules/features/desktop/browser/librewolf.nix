{
  flake.homeModules.librewolf =
    {
      pkgs,
      lib,
      ...
    }:
    let
      common = import ./_common { inherit pkgs lib; };
      rycee-firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
    in
    {

      programs.librewolf = {
        enable = true;
        nativeMessagingHosts = common.nativeMessagingHosts;

        globalExtensions = [
          # Add vanilla plugins here.

        ]
        # Sourced from rycee
        # https://nur.nix-community.org/repos/rycee/
        ++ (with rycee-firefox-addons; [

          catppuccin-mocha-mauve
          github-file-icons
          # fake-filler
          # sponsorblock
          {
            package = ublock-origin;
            settings = {
              private_browsing = true;
            };
          }
          {
            package = darkreader;
            settings = {
              private_browsing = true;
            };
          }
          {
            package = sidebery;
            settings = {
              private_browsing = true;
            };
          }
          {
            package = vimium-c;
            settings = {
              private_browsing = true;
            };
          }
          {
            package = clearurls;
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
          }
        ]);

        profiles.default = {
          isDefault = true;
          settings = {
          };

          search = common.search;

          userChrome =
            # css
            ''
              #TabsToolbar { display: none !important; }
              * { border-radius: 0px !important; }
            '';
        };
      };
    };
}
