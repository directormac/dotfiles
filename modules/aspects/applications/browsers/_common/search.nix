{ pkgs }:
let
  nixSnowflakeIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
in
{
  force = true;
  default = "google";
  engines = {
    "Nix Packages" = {
      urls = [
        {
          template = "https://search.nixos.org/packages";
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
        }
      ];
      icon = nixSnowflakeIcon;
      definedAliases = [ "@pkgs" ];
    };

    "Nix Options" = {
      urls = [
        {
          template = "https://search.nixos.org/options";
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
        }
      ];
      icon = nixSnowflakeIcon;
      definedAliases = [ "@nop" ];
    };

    "Nix Home Options" = {
      urls = [
        {
          template = "https://search.nixos.org/options";
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
        }
      ];
      icon = nixSnowflakeIcon;
      definedAliases = [ "@nhop" ];
    };

    "Home Manager Options" = {
      urls = [
        {
          template = "https://home-manager-options.extranix.com/";
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
        }
      ];
      icon = nixSnowflakeIcon;
      definedAliases = [ "@hmo" ];
    };

    "Github Search" = {
      name = "GitHub Search";
      urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
      definedAliases = [ "@gh" ];
    };

    "Github Code" = {
      urls = [ { template = "https://github.com/search?q={searchTerms}type=code"; } ];
      definedAliases = [ "@ghc" ];
    };

    "Github Repos" = {
      urls = [ { template = "https://github.com/search?q={searchTerms}type=repositories"; } ];
      definedAliases = [ "@ghc" ];
    };

    "Github Discussions" = {
      urls = [ { template = "https://github.com/search?q={searchTerms}type=discussions"; } ];
      definedAliases = [ "@ghd" ];
    };

    "Github Commits" = {
      urls = [ { template = "https://github.com/search?q={searchTerms}type=commits"; } ];
      definedAliases = [ "@ghcc" ];
    };

    "Gists" = {
      urls = [ { template = "https://gist.github.com/search?q={searchTerms}type=commits"; } ];
      definedAliases = [ "@ghcc" ];
    };

    "Youtube" = {
      urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
      definedAliases = [ "@yt" ];
    };

    "Youtube Music" = {
      urls = [ { template = "https://music.youtube.com/search?q={searchTerms}"; } ];
      definedAliases = [ "@ym" ];
    };

    "Google Maps" = {
      urls = [
        {
          template = "http://maps.google.com";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [
        "@maps"
        "@gmaps"
      ];
    };

    "StartPage" = {
      urls = [
        {
          template = "https://www.startpage.com/sp/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [
        "@startpage"
        "@sp"
        "@pp"
      ];
      icon = "https://www.startpage.com/sp/cdn/favicons/favicon-gradient.ico";
      updateInterval = 24 * 60 * 60 * 1000;
    };

    "ddg" = {
      urls = [
        {
          template = "https://duckduckgo.com";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [
        "@duck"
        "@ddg"
        "@dck"
        "@dckk"
      ];
    };

    bing.metaData.hidden = true;
    google.metaData.alias = "@g";
  };
}
