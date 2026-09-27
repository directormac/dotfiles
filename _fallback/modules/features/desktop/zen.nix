# Options https://zen-browser-flake.nshard.com/
# References https://github.com/luisnquin/nixos-config/blob/main/home/modules/programs/browser/zen/policies-config.nix
{
  inputs,
  self,
  ...
}:

{
  flake.homeModules.zen =
    { pkgs, ... }:
    let
      # https://nur.nix-community.org/repos/rycee/
      rycee-firefox-addons = pkgs.nur.repos.rycee.firefox-addons;

      spaces = {
        personal = "1fb46130-1153-4ad8-9715-747ec005d132";
        dev = "9ace6c68-8e8f-49f0-ab2f-3825b9bb0a5a";
      };

      pins = {
        gmail = "18cef5fd-c657-4c71-9b4c-273056461be9";
        email = "c6d1c67e-f0a7-474d-a558-cccdf7d967fa";
      };
    in
    {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        # Native messaging hosts for browser-application communication
        # Reference: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_messaging
        nativeMessagingHosts = [
          pkgs.firefoxpwa
        ];

        policies =
          let
            mkExtensionSettings = builtins.mapAttrs (
              _: pluginId: {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
                installation_mode = "force_installed";
              }
            );
          in
          {
            ExtensionSettings = mkExtensionSettings {
              "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = "github-file-icons";
              "{934e4b4a-2961-47d1-b507-4a91ac962cc3}" = "volume-control-boost-volume";
              "{0fb8975d-7539-4a2a-b439-f3254ef02571}" = "sponsorblock";
            };
          };

        env = { };

        globalExtensions =
          [ ]
          ++ (with rycee-firefox-addons; [
            {
              package = darkreader;
              settings = {
                private_browsing = true;
              };
            }
            {
              package = vimium;
              settings = {
                private_browsing = true;
              };
            }
            {
              package = ublock-origin;
              settings = {
                private_browsing = true;
              };
            }

          ]);

        profiles.default = {

          settings = {
            /**
              use double quotes!
            */
            "zen.theme.hide-unified-extensions-button" = false;
            "zen.workspaces.continue-where-left-off" = true;

            # Zen Complete Compact
            "zen.view.compact.hide-tabbar" = true;
            "zen.view.compact.hide-toolbar" = true;
            "zen.view.sidebar-expanded" = false;
            "zen.view.use-single-toolbar" = false;

            "zen.urlbar.behavior" = "float";
            "zen.welcome-screen.seen" = true;
          };

          # Catppuccin theme integration
          presets.catppuccin = {
            enable = true;
            flavor = "Mocha";
            accent = "Mauve";
          };

          extensions = {
            packages =
              [ ]
              ++ (with rycee-firefox-addons; [
                bitwarden
              ]);
            settings = { };
          };

          # Search engine configuration with custom shortcuts
          # Reference: https://github.com/nix-community/home-manager/blob/master/modules/programs/firefox/profiles/search.nix
          search = {
            force = true;
            default = "ddg";
            # Extra Engines
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
                urls = [
                  {
                    template = "https://github.com/search?q={searchTerms}";
                  }
                ];
                definedAliases = [ "@gh" ];
              };
              # mynixos = {
              #   name = "My NixOS";
              #   urls = [
              #     {
              #       template = "https://mynixos.com/search?q={searchTerms}";
              #       params = [
              #         {
              #           name = "query";
              #           value = "searchTerms";
              #         }
              #       ];
              #     }
              #   ];
              #   icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              #   definedAliases = [ "@nx" ];
              # };
            };
          };

          # Keys are CustomizableUI areas:
          #
          #   nav-bar                  the toolbar itself ("pin to toolbar")
          #   unified-extensions-area  the extensions panel (the default)
          #   zen-sidebar-top-buttons  Zen's sidebar, above the tabs
          #   zen-sidebar-foot-buttons Zen's sidebar, below the tabs
          #
          # Zen hides the panel's toolbar (puzzle) button by default; set
          # settings."zen.theme.hide-unified-extensions-button" = false to reach
          # buttons declared in unified-extensions-area from the toolbar.
          #
          # Ids come from about:debugging#/runtime/this-firefox, or from
          # `browser.uiCustomization.state` in about:config (there they already
          # carry the `-browser-action` suffix; those are accepted verbatim).
          extensionButtons = {
            "nav-bar" = [
              "addon@darkreader.org"
            ];

            "unified-extensions-area" = [
              # "addon@darkreader.org"
            ];

            # The placements are merged into the layout Zen saved last, so anything you
            # never declared keeps its place. A profile that has never run Zen has no
            # layout to merge into: launch it once, close it, and rebuild.
          };

          bookmarks = {
            force = true;
            settings = [
              {
                name = "Quick Links";
                toolbar = true;
                bookmarks = [
                  {
                    name = "GitHub";
                    url = "https://github.com";
                  }
                ];
              }
            ];
          };

          containersForce = true; # Delete containers not declared here
          containers = {
            Work = {
              color = "blue";
              icon = "briefcase";
              id = 1;
            };
          };

          # Zen Spaces with custom gradient themes
          # Spaces are workspaces for organizing tabs across different contexts.
          # ⚠ Only if using spaces or spacesForce: close Zen before home-manager switch
          # (activation script decompresses zen-sessions.jsonlz4, modifies with jq, recompresses)
          ## Note: Changing a space's id re-creates it as new, losing opened tabs.
          # If spacesForce = true, the old space is deleted.
          spacesForce = true; # Delete spaces not declared here
          spaces = {
            "Personal" = {
              id = spaces.personal;
              position = 1000;
              icon = "🏠";

              # Pins can be declared under their space instead of the flat
              # `pins` + `workspace` pairing (see 10-pinned-tabs.nix).
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

          };

          # Pinned tabs with groups, folders, and container assignment
          # Two declaration forms, freely mixable:
          #   - flat `pins`, targeting a space via `workspace = <spaceId>`
          #   - `spaces.<name>.pins`, same options minus `workspace` (derived from
          #     the owning space's `id`); participates in `pinsForce` accounting
          #     like any other declared pin
          # Folders, two forms, freely mixable:
          #   - embedded: nest children under the folder pin's `pins` — `isGroup` is
          #     implied, children inherit `workspace` and `folderParentId`, nesting
          #     can go deeper
          #   - flat: declare the folder with `isGroup = true` and point siblings at
          #     it via `folderParentId = pins."<folder>".id`
          #
          # ⚠ Only if using pins or pinsForce: close Zen before home-manager switch
          # (activation script needs exclusive access to modify zen-sessions.jsonlz4)
          # pinsForce = true;
          # pinsForceAction = "remove"; # "remove" drops undeclared pins; default is "demote"
          # pins = {
          #   "GitHub" = {
          #     id = "48e8a119-5a14-4826-9545-91c8e8dd3bf6";
          #     url = "https://github.com";
          #     position = 101;
          #   };
          # };
          #
          # Declarative keyboard shortcut overrides with version protection
          # Version protection detects breaking changes after Zen updates.
          # ⚠ Only if modifying keyboardShortcuts: close Zen before home-manager switch
          # (activation script modifies zen-keyboard-shortcuts.json, which is locked while browser runs)
          # Version check prevents silent breakage if Zen updates change the shortcuts schema.
          keyboardShortcuts = [
            {
              id = "zen-compact-mode-toggle";
              key = "c";
              modifiers = {
                control = true;
                alt = true;
              };
            }
            {
              id = "zen-toggle-sidebar";
              key = "x";
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
            # Find shortcut IDs in ~/.config/zen/default/zen-keyboard-shortcuts.json
            # Get version from about:config -> zen.keyboard.shortcuts.version
            # Activation fails if version changes (prevents silent breakage).
            #
            # Use this command:
            # jq -c '.shortcuts[] | {id, key, keycode, action}' ~/.config/zen/default/zen-keyboard-shortcuts.json | fzf
          ];
          # In order to avoid breaking changes here, sometimes when you upgrade you
          # should be asked to bump this version
          keyboardShortcutsVersion = 20;

          # --- Zen Mods ---

          mods = [
            "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
            "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
            "c6813222-6571-4ba6-8faf-58f3343324f6" # Disable Rounded Corners
          ];

        };

        # Betterfox for Zen (yokoffing/Betterfox zen/user.js, aka BetterZen):
        # privacy/telemetry/performance prefs applied as mkDefault settings —
        # any profile `settings` entry wins.
        profiles.default.presets.betterfox.enable = true;

        # arkenfox for Zen (arkenfox/user.js)
        profiles.default.presets.arkenfox.enable = true;

      };
    };

  flake.nixosModules.zen = { config, ... }: {
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.zen
      ];
    };
  };
}
