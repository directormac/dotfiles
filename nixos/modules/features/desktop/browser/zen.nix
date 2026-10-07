# Options: https://zen-browser-flake.nshard.com/
# References: https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/default.nix
{
  inputs,
  self,
  ...
}:

{
  flake.homeModules.zen-browser =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      common = import ./_common { inherit pkgs lib; };

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
    in
    {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      stylix.targets.zen-browser = {
        enable = false;
        profileNames = [ "default" ];
      };

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        nativeMessagingHosts = common.nativeMessagingHosts;
        policies = common.policies;

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

            # Permission blocks for local network port-scanning
            "permissions.default.loopback-network" = 2;
            "permissions.default.local-network" = 2;
          };

          presets.catppuccin = {
            enable = true;
            flavor = "Mocha";
            accent = "Mauve";
          };

          extensions = {
            packages = common.extensions.packages;
            settings = common.extensions.settings;
          };

          search = common.search;
          extensionButtons = common.extensions.extensionButtons;

          containersForce = true;
          containers = { };

          spaceRouting = {
            force = true;
            defaultExternalRoute = spaces.personal;
            routes = {
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
                reference = "^https?://(?!(www|gemini)\\.)([a-zA-Z0-9_-]+\\.)+google\\.[a-z.]+";
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
                assignedMe = true;
                reviewRequested = true;
                authorMe = true;
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
            "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
            "7190e4e9-bead-4b40-8f57-95d852ddc941" # Tab title fixes
            "803c7895-b39b-458e-84f8-a521f4d7a064" # Hide Inactive Workspaces
            "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
            "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
            # "cb15abdb-0514-4e09-8ce5-722cf1f4a20f" # Hide Extension Name
            "d8b79d4a-6cba-4495-9ff6-d6d30b0e94fe" # Better Active Tab
            # "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
            "bd92a9a0-1c00-4187-a66e-94c389fa5a59" # Sidebar Expand on Hover
            "181e41d4-dfd3-410d-9a73-561381a2f77d" # Extensions List
            "b0f635d7-c3bf-4709-af68-4712f0e5b2e56" # Cleaner Bookmark Menu
            "context-menu-icons"
          ];

          userContent = ''
            @import "catppuccin/userContent.css";
          '';

          userChrome =
            # css
            ''
              @import "catppuccin/userChrome.css";

              /* Better Find Bar Native Styles */
              ${common.findbarCss}

              /* Disable Rounded Corners */
              :root {
                --zen-webview-border-radius: 0 !important;
              }

              #zen-workspaces-button .subviewbutton:not([active="true"]) {
                display: none !important;
              }

              /* https://zen-browser.app/mods/803c7895-b39b-458e-84f8-a521f4d7a064/ */
              #zen-workspaces-button:hover .subviewbutton:not([active="true"]) {
                display: flex !important;
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
}
