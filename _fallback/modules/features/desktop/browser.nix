# Options https://zen-browser-flake.nshard.com/
# References https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/policies-config.nix
{
  inputs,
  self,
  ...
}:

{
  flake.homeModules.browser =
    { pkgs, config, ... }:
    let
      # https://nur.nix-community.org/repos/rycee/
      rycee-firefox-addons = pkgs.nur.repos.rycee.firefox-addons;

      spaces = {
        personal = "1fb46130-1153-4ad8-9715-747ec005d132";
        dev = "9ace6c68-8e8f-49f0-ab2f-3825b9bb0a5a";
        media = "e239600a-4876-4713-a10c-715c570afdc5";
        read = "e2214a3b-4fef-4d0c-ae56-decae3f63bee";
        scratchpad_one = "4ef320b6-0d78-4d8e-86d7-b503e4eece7b";
        scratchpad_two = "a38ef7bc-93aa-44ba-a6b6-474e83b71687";
      };

      pins = {
        gmail = "18cef5fd-c657-4c71-9b4c-273056461be9";
        email = "c6d1c67e-f0a7-474d-a558-cccdf7d967fa";
        messenger = "f39b9438-6cc8-4a23-ad9a-152aed130088";
        youtube = "5ac3b9d5-deeb-4f48-b28c-e84770910d9f";
        bluesky = "519bff13-7f32-4725-92a1-628b1620031e";
      };

      sharedNativeMessagingHosts = [
        pkgs.firefoxpwa
        pkgs.bitwarden-desktop
      ];

      # Common browser policies configuration
      # Reference: https://mozilla.github.io/policy-templates/
      # https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/policies-config.nix
      sharedPolicies =
        let
          mkExtensionSettings = builtins.mapAttrs (
            _: pluginId: {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
              installation_mode = "force_installed";
              private_browsing = true;
              # Explicitly declare it's allowed to be a theme
              allowed_types = [
                "extension"
                "theme"
              ];
            }
          );
        in
        {
          ExtensionSettings =
            mkExtensionSettings {
              "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = "catppuccin-mocha-mauve-git";
              "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = "github-file-icons";
              "{934e4b4a-2961-47d1-b507-4a91ac962cc3}" = "volume-control-boost-volume";
            }
            // {
              "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
                default_area = "navbar";
                private_browsing = true;
              };
              "addon@darkreader.org" = {
                default_area = "navbar";
                private_browsing = true;
              };
              "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
                private_browsing = true;
              };
              "uBlock0@raymondhill.net" = {
                private_browsing = true;
              };
              "sponsorBlocker@ajay.app" = {
                private_browsing = true;
              };
            };

          DontCheckDefaultBrowser = true;
          HardwareAcceleration = true;
          ManualAppUpdateOnly = true;
          NoDefaultBookmarks = false;
          OfferToSaveLogins = false;
          PasswordManagerEnabled = false;
          OfferToSaveLoginsDefault = false;

          PictureInPicture = {
            Enabled = true;
          };

          EncryptedMediaExtensions = {
            Enabled = true;
          };

          FirefoxHome = {
            Search = false;
            TopSites = false;
            SponsoredTopSites = false;
            Highlights = false;
            Pocket = false;
            SponsoredPocket = false;
            Snippets = false;
            Locked = false;
          };

          EnableTrackingProtection = {
            Value = true;
            Locked = false;
            Cryptomining = true;
            Fingerprinting = true;
          };

          # Reference: https://mozilla.github.io/policy-templates/#preferences
          Preferences = {
            "browser.tabs.warnOnClose" = {
              Value = false;
            };
          };
        };

      sharedExtensionsPackages = with rycee-firefox-addons; [
        bitwarden
        clearurls
        darkreader
        sponsorblock
        ublock-origin
        vimium
      ];

      # Reference: https://github.com/nix-community/home-manager/blob/master/modules/programs/firefox/profiles/search.nix
      sharedSearch = {
        force = true;
        default = "google";
        engines =
          let
            nixSnowflakeIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          in
          {
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
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
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
      };

      # https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/bookmarks-config.nix
      # sharedBookmarks = {
      #   force = true;
      #   settings = [
      #     {
      #       name = "Quick Links";
      #       toolbar = true;
      #       bookmarks = [
      #         {
      #           name = "GitHub";
      #           url = "https://github.com";
      #         }
      #       ];
      #     }
      #   ];
      # };

    in
    {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      stylix.targets = {
        zen-browser = {
          enable = false;
          profileNames = [ "default" ];
        };

        firefox = {
          enable = true;
          profileNames = [ "default" ];
        };
      };

      programs.firefox = {
        enable = true;
        nativeMessagingHosts = sharedNativeMessagingHosts;
        policies = sharedPolicies;
        profiles.default = {
          isDefault = true;
          settings = {
            "extensions.allowPrivateBrowsingByDefault" = true;
          };
          extensions = {
            packages = sharedExtensionsPackages;
            settings = { };
          };
          search = sharedSearch;
          userChrome =
            # css
            ''
              :root {
                --tab-border-radius: 0px !important;
                --border-radius-small: 0px !important;
                --border-radius-medium: 0px !important;
              }
            '';

          # bookmarks = sharedBookmarks;
        };
      };

      # xdg.mimeApps =
      #   let
      #     associations = builtins.listToAttrs (
      #       map
      #         (name: {
      #           inherit name;
      #           value =
      #             let
      #               zen-browser = config.programs.zen-browser.package;
      #             in
      #             zen-browser.meta.desktopFileName;
      #         })
      #         [
      #           "application/x-extension-shtml"
      #           "application/x-extension-xhtml"
      #           "application/x-extension-html"
      #           "application/x-extension-xht"
      #           "application/x-extension-htm"
      #           "x-scheme-handler/unknown"
      #           "x-scheme-handler/mailto"
      #           "x-scheme-handler/chrome"
      #           "x-scheme-handler/about"
      #           "x-scheme-handler/https"
      #           "x-scheme-handler/http"
      #           "application/xhtml+xml"
      #           "application/json"
      #           # "text/plain"
      #           "text/html"
      #         ]
      #     );
      #   in
      #   {
      #     associations.added = associations;
      #     defaultApplications = associations;
      #   };

      # Reference https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/default.nix
      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        nativeMessagingHosts = sharedNativeMessagingHosts;

        policies = sharedPolicies;

        env = {
          MOZ_ENABLE_WAYLAND = "1";
        };

        profiles.default = {

          settings = {
            "browser.tabs.warnOnClose" = false;

            "browser.tabs.insertAfterCurrent" = false;
            "browser.tabs.insertAfterCurrentExceptPinned" = false;
            "gfx.webrender.all" = true;

            "extensions.allowPrivateBrowsingByDefault" = true;

            "zen.theme.border-radius" = 0;
            "zen.ui.migration.compact-mode-button-added" = true;
            "zen.theme.content-element-seperation" = 0;
            "zen.urlbar.behavior" = "float";
            "zen.view.show-newtab-button-top" = true;
            "zen.view.compact.hide-tabbar" = true;
            "zen.view.compact.hide-toolbar" = true;
            "zen.view.sidebar-expanded" = false;
            "zen.view.use-single-toolbar" = false;
            "zen.view.compact.enable-at-startup" = true;
            "zen.welcome-screen.seen" = true;
            "zen.workspaces.natural-scroll" = true;
            "zen.view.compact.animate-sidebar" = false;
            "zen.theme.hide-unified-extensions-button" = true;
            "zen.workspaces.continue-where-left-off" = true;
            # "<site> wants to access other apps and services on this device" is the
            # local network access prompt (loopback-network/local-network), not WebMIDI;
            # shops like aliexpress port-scan 127.0.0.1 to fingerprint. 2 = BLOCK, and
            # PermissionUI cancels the request instead of drawing a doorhanger.
            "permissions.default.loopback-network" = 2;
            "permissions.default.local-network" = 2;
          };

          presets.catppuccin = {
            enable = true;
            flavor = "Mocha";
            accent = "Mauve";
          };

          extensions = {
            packages = sharedExtensionsPackages;
            settings = {
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
          };

          search = sharedSearch;
          # bookmarks = sharedBookmarks;

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

          containersForce = true;
          containers = {
            # Work = {
            #   color = "blue";
            #   icon = "briefcase";
            #   id = 1;
            # };
          };

          spaceRouting = {
            force = true;
            defaultExternalRoute = spaces.personal;
            # https://github.com/0xc000022070/zen-browser-flake/blob/main/hm-module/session/space-routing.nix
            routes = {
              # "Github" = {
              #   reference = "^https?://(www\\.)?github\\.[a-z.]+(/|$|search|\\?)";
              #   matchType = "regex";
              #   openIn = spaces.dev;
              # };
              # "reddit" = {
              #   reference = "reddit.com";
              #   matchType = "equal-to";
              #   openIn = spaces.read;
              # };
              "medium" = {
                reference = "medium.com";
                matchType = "equal-to";
                openIn = spaces.read;
              };
              "dev.to" = {
                reference = "dev.to";
                matchType = "equal-to";
                openIn = spaces.read;
              };
              "google-services" = {
                reference = "^https?://(?!www\\.)([a-zA-Z0-9_-]+\\.)+google\\.[a-z.]+";
                matchType = "regex";
                openIn = spaces.personal;
              };
              "google-search" = {
                reference = "^https?://(www\\.)?google\\.[a-z.]+(/|$|search|\\?)";
                matchType = "regex";
                openIn = "most-recent-space";
              };
            };
          };

          # Reference https://github.com/0xc000022070/zen-browser-flake/blob/main/examples/18-space-routing.nix
          spacesForce = true;
          spaces = {
            "Personal" = {
              id = spaces.personal;
              position = 1000;
              icon = "🏠";
              pins = {
                "Email" = {
                  id = pins.email;
                  url = "https://inbox.purelymail.com";
                  position = 100;
                };
                "Gmail" = {
                  id = pins.gmail;
                  url = "https://mail.google.com";
                  position = 200;
                };
                "Messenger" = {
                  id = pins.messenger;
                  url = "https://messenger.com";
                  position = 300;
                };
              };
            };
            "Dev" = {
              id = spaces.dev;
              position = 2000;
              icon = "👨‍💻";
              pins = {
                "Github" = {
                  id = "06821413-a423-482c-9365-d7e70d14b8e8";
                  url = "https://github.com";
                  position = 100;
                };
                "Dotfiles" = {
                  id = "1c971ba4-3527-4ce9-9317-52731bdbb39a";
                  url = "https://github.com/directormac/dotfiles";
                  position = 300;
                };
              };

            };
            "Scratchpad 1" = {
              id = spaces.scratchpad_one;
              position = 3000;
              icon = "📝";
            };
            "Scratchpad 2" = {
              id = spaces.scratchpad_two;
              position = 4000;
              icon = "🗒️";
            };
            "Read" = {
              id = spaces.read;
              position = 5000;
              icon = "📖";
            };
            "Media" = {
              id = spaces.media;
              position = 6000;
              icon = "📺";
            };
          };

          liveFolders = {

            "Hacker News" = {
              id = "fbdea31b-e0c7-4f0e-b4fb-2f0b8cfa8237";
              collapsed = true;
              workspace = spaces.read;
              feedUrl = "https://hnrss.org/newest";
              kind = "rss";
              position = 401;
            };

            "Dev.to" = {
              id = "92039a58-2ecb-414c-899f-d1bd4b8ea447";
              collapsed = true;
              workspace = spaces.read;
              feedUrl = "https://dev.to/feed";
              kind = "rss";
              position = 402;
            };

            "Code Signal" = {
              id = "20c2656e-5eb9-42c5-803d-618d369171c6";
              collapsed = true;
              workspace = spaces.read;
              feedUrl = "https://codesignal.com/feed/";
              kind = "rss";
              position = 403;
            };

            "Mozilla Hacks" = {
              id = "8b3d6e52-97e5-4864-956e-b84efb6c1eaf";
              collapsed = true;
              workspace = spaces.read;
              feedUrl = "https://hacks.mozilla.org/feed/";
              kind = "rss";
              position = 404;
            };

            "Pull requests" = {
              id = "7f949efb-b5ad-4b0d-910d-f4dadf712cc5";
              kind = "github:pull-requests";
              workspace = spaces.dev;
              collapsed = true;
              position = 401;
              github = {
                assignedMe = true; # default
                reviewRequested = true;
                authorMe = true;
                # repoExcludes = ["owner/noisy-repo"];
              };
            };

            "My issues" = {
              id = "b50b2791-4bf2-465b-8495-f9d14ca70913";
              kind = "github:issues";
              workspace = spaces.dev;
              collapsed = true;
              position = 402;
              github.authorMe = true;
            };
          };

          # Check shortcuts
          # jq -c '.shortcuts[] | {id, key, keycode, action}' ~/.config/zen/default/zen-keyboard-shortcuts.json | tv
          keyboardShortcuts =
            (map (i: {
              id = "zen-workspace-switch-${toString i}";
              key = toString i;
              modifiers = {
                alt = true;
              };
            }) (pkgs.lib.range 1 6))
            ++ (map (i: {
              id = "key_selectTab${toString i}";
              disabled = true;
            }) (pkgs.lib.range 1 6))
            ++ [
              {
                id = "zen-compact-mode-toggle";
                key = "c";
                modifiers = {
                  control = true;
                  alt = true;
                };
              }
              {
                id = "zen-compact-mode-show-sidebar";
                key = "s";
                modifiers = {
                  control = true;
                  alt = true;
                };
              }
              {
                id = "key_quitApplication";
                disabled = true;
              }
              {
                id = "key_reload";
                key = "r";
                modifiers.control = true;
              }
              {
                id = "key_reload_skip_cache";
                key = "r";
                modifiers = {
                  control = true;
                  shift = true;
                };
              }
            ];
          keyboardShortcutsVersion = 20;

          mods = [
            "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
            "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
            "7190e4e9-bead-4b40-8f57-95d852ddc941" # Tab title fixes
            "803c7895-b39b-458e-84f8-a521f4d7a064" # Hide Inactive Workspaces
            "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
            "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
            "cb15abdb-0514-4e09-8ce5-722cf1f4a20f" # Hide Extension Name
            "d8b79d4a-6cba-4495-9ff6-d6d30b0e94fe" # Better Active Tab
            "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
            "bd92a9a0-1c00-4187-a66e-94c389fa5a59" # Sidebar Expand on Hover
            "181e41d4-dfd3-410d-9a73-561381a2f77d" # Extensions List
            "b0f635d7-c3bf-4709-af68-4712f0e5b2e56" # Cleaner Bookmark Menu
            # "3ff55ba7-4690-4f74-96a8-9e4416685e4e6" # Colored container tab
            # https://www.sameerasw.com/zen
            # "642854b5-88b4-4c40-b256-e035532109df" # Transparent Zen
            "context-menu-icons"
          ];

          userContent =
            # css
            ''
              @import "catppuccin/userContent.css";
            '';

          userChrome =
            # css
            ''
              @import "catppuccin/userChrome.css";

              /* Disable Rounded Corners */
              :root {
                --zen-webview-border-radius: 0 !important;
              }

              #zen-workspaces-button .subviewbutton:not([active="true"]) {
                display: none!important;
              }

              /* https://zen-browser.app/mods/803c7895-b39b-458e-84f8-a521f4d7a064/ */
              #zen-workspaces-button:hover .subviewbutton:not([active="true"]) {
                display: flex!important;
              }

              /* https://zen-browser.app/mods/4ab93b88-151c-451b-a1b7-a1e0e28fa7f8/ */
              @media not (-moz-pref("theme.nosidebarscrollbar.before125b")) {
                  scrollbox:nth-child(5) {
                      scrollbar-width: none !important;
                  }
              }

              @media (-moz-pref("theme.nosidebarscrollbar.before125b")) {
                  #zen-tabs-wrapper {
                      scrollbar-width: none !important;
                  }
              }

              #tabbrowser-tabpanels:not([zen-split-view="true"]) {
                padding-left: 0px !important;
                padding-right: 0px !important;
              }

              #urlbar {
                @media -moz-pref("mod.ivaon.urlbar.hide_results", "0") {
                  &:not([usertyping], [searchmode])>.urlbarView {
                    display: none !important;
                  }
                }
                #urlbar-results div.urlbarView-row[row-selectable][type="top_site"] {
                  @media -moz-pref("mod.ivaon.urlbar.hide_results", "0"), -moz-pref("mod.ivaon.urlbar.hide_results", "1") {
                    & {
                      display: none !important;
                    }
                  }
                  @media -moz-pref("mod.ivaon.urlbar.hide_results", "2") {
                    &:not([pinned]) {
                      display: none !important;
                    }
                  }
                }
              }


            '';

        };

        profiles.default.presets.betterfox.enable = true;
      };
    };

  flake.nixosModules.browser = { config, ... }: {
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.browser
      ];
    };
  };
}
