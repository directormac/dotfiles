# Options https://zen-browser-flake.nshard.com/
# References https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/policies-config.nix
{
  inputs,
  self,
  ...
}:

{
  flake.homeModules.browser =
    { pkgs, ... }:
    let
      # https://nur.nix-community.org/repos/rycee/
      rycee-firefox-addons = pkgs.nur.repos.rycee.firefox-addons;

      banditthedoge-firefoxAddons = pkgs.nur.repos.bandithedoge.firefoxAddons;

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
      };

      sharedNativeMessagingHosts = [
        pkgs.firefoxpwa
        pkgs.bitwarden-desktop
      ];

      sharedPolicies =
        let
          mkExtensionSettings = builtins.mapAttrs (
            _: pluginId: {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
              installation_mode = "force_installed";
            }
          );
        in
        {
          ExtensionSettings =
            mkExtensionSettings {
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
                default_area = "navbar";
                private_browsing = true;
              };
              "uBlock0@raymondhill.net" = {
                default_area = "navbar";
                private_browsing = true;
              };
              "sponsorBlocker@ajay.app" = {
                default_area = "navbar";
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

          Preferences = {
            "browser.tabs.warnOnClose" = {
              Value = false;
            };
          };
        };

      sharedExtensionsPackages = [

        banditthedoge-firefoxAddons.sponsorblock
      ]
      ++ (with rycee-firefox-addons; [
        bitwarden
        darkreader
        vimium
        ublock-origin
      ]);

      sharedSearch = {
        force = true;
        default = "google";
        engines = {
          nixpkgs = {
            name = "NixOS Packages";
            urls = [
              {
                template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
                programs = [
                  {
                    name = "query";
                    value = "searchTerms";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nix" ];
          };
          nixoptions = {
            name = "NixOS Options";
            urls = [
              {
                template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
                programs = [
                  {
                    name = "query";
                    value = "searchTerms";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nixops" ];
          };
          hmoptions = {
            name = "Home Manager Options";
            urls = [
              {
                template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
                programs = [
                  {
                    name = "query";
                    value = "searchTerms";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };
          github = {
            name = "GitHub Search";
            urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
            definedAliases = [ "@gh" ];
          };
        };
      };

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
          # bookmarks = sharedBookmarks;
        };
      };

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        nativeMessagingHosts = sharedNativeMessagingHosts;
        package = inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default.override {
          nativeMessagingHosts = sharedNativeMessagingHosts;
        };

        policies = sharedPolicies;

        env = {
          MOZ_ENABLE_WAYLAND = "1";
        };

        profiles.default = {

          settings = {
            "extensions.allowPrivateBrowsingByDefault" = true;
            "zen.theme.hide-unified-extensions-button" = false;
            "zen.theme.content-element-seperation" = 0;
            "zen.theme.border-radius" = 0;
            "zen.workspaces.continue-where-left-off" = true;

            "zen.view.compact.hide-tabbar" = true;
            "zen.view.compact.hide-toolbar" = true;
            "zen.view.sidebar-expanded" = false;
            "zen.view.use-single-toolbar" = false;

            "browser.tabs.insertAfterCurrent" = true;
            "browser.tabs.insertAfterCurrentExceptPinned" = true;
            "zen.urlbar.behavior" = "float";
            "zen.welcome-screen.seen" = true;
          };

          presets.catppuccin = {
            enable = true;
            flavor = "Mocha";
            accent = "Mauve";
          };

          extensions = {
            packages = sharedExtensionsPackages;
            settings = { };
          };

          search = sharedSearch;
          # bookmarks = sharedBookmarks;

          extensionButtons = {
            "nav-bar" = [
              "addon@darkreader.org"
            ];
            "unified-extensions-area" = [
            ];
          };

          containersForce = true;
          containers = {
            Work = {
              color = "blue";
              icon = "briefcase";
              id = 1;
            };
          };

          spaceRouting = {
            defaultExternalRoute = spaces.scratchpad_one;
            routes = {
              "github" = {
                reference = "github.com";
                matchType = "contains";
                openIn = spaces.dev;
              };
              "reddit" = {
                reference = "reddit.com";
                matchType = "equal-to";
                openIn = spaces.read;
              };
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
            };
          };

          spacesForce = true;
          spaces = {
            "Personal" = {
              id = spaces.personal;
              position = 1000;
              icon = "🏠";
              pins."Email" = {
                id = pins.email;
                url = "https://inbox.purelymail.com";
                position = 100;
              };
              pins."Gmail" = {
                id = pins.gmail;
                url = "https://mail.google.com";
                position = 200;
              };
            };
            "Dev" = {
              id = spaces.dev;
              position = 2000;
              icon = "👨‍💻";
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

          keyboardShortcuts = [
            {
              id = "zen-workspace-switch-1";
              key = "1";
              modifiers = {
                alt = true;
              };
            }
            {
              id = "zen-workspace-switch-2";
              key = "2";
              modifiers = {
                alt = true;
              };
            }
            {
              id = "zen-workspace-switch-3";
              key = "3";
              modifiers = {
                alt = true;
              };
            }
            {
              id = "zen-workspace-switch-4";
              key = "4";
              modifiers = {
                alt = true;
              };
            }
            {
              id = "zen-workspace-switch-5";
              key = "5";
              modifiers = {
                alt = true;
              };
            }
            {
              id = "zen-workspace-switch-6";
              key = "6";
              modifiers = {
                alt = true;
              };
            }
            {
              id = "key_selectTab1";
              disabled = true;
            }
            {
              id = "key_selectTab2";
              disabled = true;
            }
            {
              id = "key_selectTab3";
              disabled = true;
            }
            {
              id = "key_selectTab4";
              disabled = true;
            }
            {
              id = "key_selectTab5";
              disabled = true;
            }
            {
              id = "key_selectTab6";
              disabled = true;
            }
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
            "253a3a74-0cc4-47b7-8b82-996a64f030d5"
            #   "e122b5d9-d385-4bf8-9971-e137809097d0"
            #   "c6813222-6571-4ba6-8faf-58f3343324f6"
          ];

          userContent =
            # css
            ''
              @import "catppuccin/userChrome.css";
            '';

          userChrome =
            # css
            ''
              @import "catppuccin/userChrome.css";

              /* .tab-icon-image { */
              /*   width: 16px; */
              /*   height: 16px; */
              /* } */


              --zen-webview-border-radius: 0;
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
