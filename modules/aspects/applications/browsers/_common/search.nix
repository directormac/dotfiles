{ pkgs }:
let
  nixSnowflakeIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
in
{
  default = "google";

  engines = {
    "Gists" = {
      definedAliases = [ "@ghcc" ];
      urls = [ { template = "https://gist.github.com/search?q={searchTerms}type=commits"; } ];
    };

    "Github Code" = {
      definedAliases = [ "@ghc" ];
      urls = [ { template = "https://github.com/search?q={searchTerms}type=code"; } ];
    };

    "Github Commits" = {
      definedAliases = [ "@ghcc" ];
      urls = [ { template = "https://github.com/search?q={searchTerms}type=commits"; } ];
    };

    "Github Discussions" = {
      definedAliases = [ "@ghd" ];
      urls = [ { template = "https://github.com/search?q={searchTerms}type=discussions"; } ];
    };

    "Github Repos" = {
      definedAliases = [ "@ghc" ];
      urls = [ { template = "https://github.com/search?q={searchTerms}type=repositories"; } ];
    };

    "Github Search" = {
      definedAliases = [ "@gh" ];
      name = "GitHub Search";
      urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
    };

    "Google Maps" = {
      definedAliases = [
        "@maps"
        "@gmaps"
      ];

      urls = [
        {
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];

          template = "http://maps.google.com";
        }
      ];
    };

    "Home Manager Options" = {
      definedAliases = [ "@hmo" ];
      icon = nixSnowflakeIcon;

      urls = [
        {
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
            {
              name = "release";
              value = "master";
            }
          ];

          template = "https://home-manager-options.extranix.com/";
        }
      ];
    };

    "Nix Home Options" = {
      definedAliases = [ "@nhop" ];
      icon = nixSnowflakeIcon;

      urls = [
        {
          params = [
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "source";
              value = "home_manager";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];

          template = "https://search.nixos.org/options";
        }
      ];
    };

    "Nix Options" = {
      definedAliases = [ "@nop" ];
      icon = nixSnowflakeIcon;

      urls = [
        {
          params = [
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];

          template = "https://search.nixos.org/options";
        }
      ];
    };

    "Nix Packages" = {
      definedAliases = [ "@pkgs" ];
      icon = nixSnowflakeIcon;

      urls = [
        {
          params = [
            {
              name = "type";
              value = "packages";
            }
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];

          template = "https://search.nixos.org/packages";
        }
      ];
    };

    "StartPage" = {
      definedAliases = [
        "@startpage"
        "@sp"
        "@pp"
      ];

      icon = "https://www.startpage.com/sp/cdn/favicons/favicon-gradient.ico";
      updateInterval = 24 * 60 * 60 * 1000;

      urls = [
        {
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];

          template = "https://www.startpage.com/sp/search";
        }
      ];
    };

    "Youtube" = {
      definedAliases = [ "@yt" ];
      urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
    };

    "Youtube Music" = {
      definedAliases = [ "@ym" ];
      urls = [ { template = "https://music.youtube.com/search?q={searchTerms}"; } ];
    };

    bing.metaData.hidden = true;

    "ddg" = {
      definedAliases = [
        "@duck"
        "@ddg"
        "@dck"
        "@dckk"
      ];

      urls = [
        {
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];

          template = "https://duckduckgo.com";
        }
      ];
    };

    google.metaData.alias = "@g";
  };

  force = true;
}
