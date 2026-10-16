# Zen Browser Leaf Aspect
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    nur.url = "github:nix-community/NUR";

    zen-browser = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:0xc000022070/zen-browser-flake";
    };
  };

  den.aspects.applications.browsers.zen = {
    nixos =
      { ... }:
      {
        imports = lib.optionals (inputs ? nur) [
          inputs.nur.modules.nixos.default
        ];
      };

    homeManager =
      {
        lib,
        pkgs,
        ...
      }:
      let
        common = import ./_common { inherit pkgs lib; };
        pins = {
          bluesky = "519bff13-7f32-4725-92a1-628b1620031e";
          email = "c6d1c67e-f0a7-474d-a558-cccdf7d967fa";
          gmail = "18cef5fd-c657-4c71-9b4c-273056461be9";
          messenger = "f39b9438-6cc8-4a23-ad9a-152aed130088";
          youtube = "5ac3b9d5-deeb-4f48-b28c-e84770910d9f";
        };
        spaces = {
          dev = "9ace6c68-8e8f-49f0-ab2f-3825b9bb0a5a";
          media = "e239600a-4876-4713-a10c-715c570afdc5";
          personal = "1fb46130-1153-4ad8-9715-747ec005d132";
          read = "e2214a3b-4fef-4d0c-ae56-decae3f63bee";
          scratchpad_one = "4ef320b6-0d78-4d8e-86d7-b503e4eece7b";
          scratchpad_two = "a38ef7bc-93aa-44ba-a6b6-474e83b71687";
        };
      in
      {
        imports = lib.optionals (inputs ? zen-browser) [
          inputs.zen-browser.homeModules.beta
        ];

        programs.zen-browser = lib.mkIf (inputs ? zen-browser) {
          inherit (common) nativeMessagingHosts;
          inherit (common) policies;
          enable = true;

          env = {
            MOZ_ENABLE_WAYLAND = "1";
          };

          profiles.default = {
            inherit (common) search;

            settings = {
              "browser.tabs.insertAfterCurrent" = false;
              "browser.tabs.insertAfterCurrentExceptPinned" = false;
              "browser.tabs.warnOnClose" = false;
              "extensions.allowPrivateBrowsingByDefault" = true;
              "gfx.webrender.all" = true;
              "permissions.default.local-network" = 2;
              # Permission blocks for local network port-scanning
              "permissions.default.loopback-network" = 2;
              "zen.theme.border-radius" = 0;
              "zen.theme.content-element-seperation" = 0;
              "zen.theme.hide-unified-extensions-button" = true;
              "zen.ui.migration.compact-mode-button-added" = true;
              "zen.urlbar.behavior" = "float";
              "zen.view.compact.animate-sidebar" = false;
              "zen.view.compact.enable-at-startup" = true;
              "zen.view.compact.hide-tabbar" = true;
              "zen.view.compact.hide-toolbar" = true;
              "zen.view.show-newtab-button-top" = true;
              "zen.view.sidebar-expanded" = false;
              "zen.view.use-single-toolbar" = false;
              "zen.welcome-screen.seen" = true;
              "zen.workspaces.continue-where-left-off" = true;
              "zen.workspaces.natural-scroll" = true;
            };

            containers = { };
            containersForce = true;
            extensionButtons = common.extensions.extensionButtons;

            extensions = {
              settings = common.extensions.settings;
              packages = common.extensions.packages;
            };

            keyboardShortcuts =
              (map (i: {
                id = "zen-workspace-switch-${toString i}";
                key = toString i;

                modifiers = {
                  alt = true;
                };
              }) (lib.range 1 6))
              ++ (map (i: {
                disabled = true;
                id = "key_selectTab${toString i}";
              }) (lib.range 1 6))
              ++ [
                {
                  id = "zen-compact-mode-toggle";
                  key = "c";

                  modifiers = {
                    alt = true;
                    control = true;
                  };
                }
                {
                  id = "zen-compact-mode-show-sidebar";
                  key = "s";

                  modifiers = {
                    alt = true;
                    control = true;
                  };
                }
                {
                  disabled = true;
                  id = "key_quitApplication";
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

            keyboardShortcutsVersion = 21;

            liveFolders = {
              "Code Signal" = {
                collapsed = true;
                feedUrl = "https://codesignal.com/feed/";
                id = "20c2656e-5eb9-42c5-803d-618d369171c6";
                kind = "rss";
                position = 403;
                workspace = spaces.read;
              };

              "Dev.to" = {
                collapsed = true;
                feedUrl = "https://dev.to/feed";
                id = "92039a58-2ecb-414c-899f-d1bd4b8ea447";
                kind = "rss";
                position = 402;
                workspace = spaces.read;
              };

              "Hacker News" = {
                collapsed = true;
                feedUrl = "https://hnrss.org/newest";
                id = "fbdea31b-e0c7-4f0e-b4fb-2f0b8cfa8237";
                kind = "rss";
                position = 401;
                workspace = spaces.read;
              };

              "Mozilla Hacks" = {
                collapsed = true;
                feedUrl = "https://hacks.mozilla.org/feed/";
                id = "8b3d6e52-97e5-4864-956e-b84efb6c1eaf";
                kind = "rss";
                position = 404;
                workspace = spaces.read;
              };

              "My issues" = {
                collapsed = true;
                github.authorMe = true;
                id = "b50b2791-4bf2-465b-8495-f9d14ca70913";
                kind = "github:issues";
                position = 402;
                workspace = spaces.dev;
              };

              "Pull requests" = {
                collapsed = true;

                github = {
                  assignedMe = true;
                  authorMe = true;
                  reviewRequested = true;
                };

                id = "7f949efb-b5ad-4b0d-910d-f4dadf712cc5";
                kind = "github:pull-requests";
                position = 401;
                workspace = spaces.dev;
              };
            };

            mods = [
              "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
              "7190e4e9-bead-4b40-8f57-95d852ddc941" # Tab title fixes
              "803c7895-b39b-458e-84f8-a521f4d7a064" # Hide Inactive Workspaces
              "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
              "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
              "d8b79d4a-6cba-4495-9ff6-d6d30b0e94fe" # Better Active Tab
              "b0f635d7-c3bf-4709-af68-4712f0e5b2e56" # Cleaner Bookmark Menu
              "context-menu-icons"
            ];

            presets.catppuccin = {
              accent = "Mauve";
              enable = true;
              flavor = "Mocha";
            };

            spaceRouting = {
              defaultExternalRoute = "most-recent-space";
              force = true;

              routes = {
                "dev.to" = {
                  matchType = "equal-to";
                  openIn = spaces.read;
                  reference = "dev.to";
                };

                "google-search" = {
                  matchType = "regex";
                  openIn = "most-recent-space";
                  reference = "^https?://(www\\.)?google\\.[a-z.]+(/|$|search|\\?)";
                };

                "google-services" = {
                  matchType = "regex";
                  openIn = spaces.personal;
                  reference = "^https?://(?!(www|gemini)\\.)([a-zA-Z0-9_-]+\\.)+google\\.[a-z.]+";
                };

                "medium" = {
                  matchType = "equal-to";
                  openIn = spaces.read;
                  reference = "medium.com";
                };
              };
            };

            spaces = {
              "Dev" = {
                icon = "👨‍💻";
                id = spaces.dev;

                pins = {
                  "Dotfiles" = {
                    id = "1c971ba4-3527-4ce9-9317-52731bdbb39a";
                    position = 300;
                    url = "https://github.com/directormac/dotfiles";
                  };

                  "Github" = {
                    id = "06821413-a423-482c-9365-d7e70d14b8e8";
                    position = 100;
                    url = "https://github.com";
                  };
                };

                position = 2000;
              };

              "Media" = {
                icon = "📺";
                id = spaces.media;
                position = 6000;
              };

              "Personal" = {
                icon = "🏠";
                id = spaces.personal;

                pins = {
                  "Email" = {
                    id = pins.email;
                    position = 100;
                    url = "https://inbox.purelymail.com";
                  };

                  "Gmail" = {
                    id = pins.gmail;
                    position = 200;
                    url = "https://mail.google.com";
                  };

                  "Messenger" = {
                    id = pins.messenger;
                    position = 300;
                    url = "https://messenger.com";
                  };
                };

                position = 1000;
              };

              "Read" = {
                icon = "📖";
                id = spaces.read;
                position = 5000;
              };

              "Scratchpad 1" = {
                icon = "📝";
                id = spaces.scratchpad_one;
                position = 3000;
              };

              "Scratchpad 2" = {
                icon = "🗒️";
                id = spaces.scratchpad_two;
                position = 4000;
              };
            };

            spacesForce = true;

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

                #zen-workspaces-button:hover .subviewbutton:not([active="true"]) {
                  display: flex !important;
                }

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

            userContent = ''
              @import "catppuccin/userContent.css";
            '';
          };

          profiles.default.presets.betterfox.enable = true;
          setAsDefaultBrowser = true;
        };

        stylix.targets.zen-browser = {
          enable = false;
          profileNames = [ "default" ];
        };
      };

    cacheHome.directories = [
      ".cache/zen"
    ];

    persistHome.directories = [
      ".config/zen"
    ];
  };

}
