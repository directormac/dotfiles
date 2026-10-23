# Firefox Browser Leaf Aspect
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.applications.browsers.firefox = {
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
        common = import ./_common { inherit pkgs; };
        customAddons = common.extensions.customAddons;
      in
      {
        home.activation.firefoxExtensionShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          common.configureExtensionCommands {
            profileDirs = [
              ".mozilla/firefox/default"
              ".config/mozilla/firefox/default"
            ];
          }
        );

        home.activation.setupFirefoxProfile = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          if [ -d "$HOME/.mozilla/firefox/r9v7k3q0.default" ] && [ ! -f "$HOME/.mozilla/firefox/default/places.sqlite" ]; then
            mkdir -p "$HOME/.mozilla/firefox/default"
            cp -rn "$HOME/.mozilla/firefox/r9v7k3q0.default"/* "$HOME/.mozilla/firefox/default/" 2>/dev/null || true
          fi
          if [ -f "$HOME/.mozilla/firefox/profiles.ini" ] && [ ! -L "$HOME/.mozilla/firefox/profiles.ini" ]; then
            mv "$HOME/.mozilla/firefox/profiles.ini" "$HOME/.mozilla/firefox/profiles.ini.bak"
          fi
        '';

        programs.firefox = {
          inherit (common) nativeMessagingHosts policies;
          enable = true;
          configPath = ".mozilla/firefox";

          globalExtensions = [
            {
              settings = {
                private_browsing = true;
              };

              package = customAddons.volume-control-boost-volume;
            }
          ]
          ++ (with common.extensions.rycee-firefox-addons; [
            catppuccin-mocha-mauve
            github-file-icons
            fake-filler
            tweaks-for-youtube
            sponsorblock
            {
              settings = {
                private_browsing = true;
              };

              package = ublock-origin;
            }
            {
              settings = {
                private_browsing = true;
              };

              package = darkreader;
            }
            {
              settings = {
                private_browsing = true;
              };

              package = sidebery;
            }
            {
              settings = {
                private_browsing = true;
              };

              package = vimium-c;
            }
            {
              settings = {
                private_browsing = true;
              };

              package = clearurls;
            }
          ]);

          profiles.default = {
            inherit (common) search;

            settings = common.sessionSettings // {
              "browser.ml.chat.enabled" = true;
              "browser.ml.chat.sidebar" = true;

              "browser.uiCustomization.navBarWhenVerticalTabs" = builtins.toJSON [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "customizableui-special-spring1"
                "vertical-spacer"
                "urlbar-container"
                "customizableui-special-spring2"
                "downloads-button"
                "fxa-toolbar-menu-button"
                "reset-pbm-toolbar-button"
                "unified-extensions-button"
                "_57e8684d-5ae8-47d6-93c9-f870ef0e40a3_-browser-action"
                "addon_darkreader_org-browser-action"
                "_3c078156-979c-498b-8990-85f7987dd929_-browser-action"
                "alltabs-button"
                "smartwindow-group-tabs-button"
                "ai-window-toggle"
              ];

              "browser.uiCustomization.state" = builtins.toJSON {
                currentVersion = 26;

                dirtyAreaCache = [
                  "nav-bar"
                  "TabsToolbar"
                  "vertical-tabs"
                  "toolbar-menubar"
                  "PersonalToolbar"
                  "unified-extensions-area"
                ];

                newElementCount = 4;

                placements = {
                  PersonalToolbar = [ "personal-bookmarks" ];
                  TabsToolbar = [ ];

                  nav-bar = [
                    "back-button"
                    "forward-button"
                    "stop-reload-button"
                    "customizableui-special-spring1"
                    "vertical-spacer"
                    "urlbar-container"
                    "customizableui-special-spring2"
                    "downloads-button"
                    "fxa-toolbar-menu-button"
                    "reset-pbm-toolbar-button"
                    "unified-extensions-button"
                    "_57e8684d-5ae8-47d6-93c9-f870ef0e40a3_-browser-action"
                    "addon_darkreader_org-browser-action"
                    "_3c078156-979c-498b-8990-85f7987dd929_-browser-action"
                    "alltabs-button"
                    "smartwindow-group-tabs-button"
                    "ai-window-toggle"
                  ];

                  toolbar-menubar = [ "menubar-items" ];

                  unified-extensions-area = [
                    "ublock0_raymondhill_net-browser-action"
                    "sponsorblocker_ajay_app-browser-action"
                    "_85860b32-02a8-431a-b2b1-40fbd64c9c69_-browser-action"
                    "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
                    "vimium-c_gdh1995_cn-browser-action"
                    "_7efbd09d-90ad-47fa-b91a-08c472bdf566_-browser-action"
                    "_84c8edb0-65ca-43a5-bc53-0e80f41486e1_-browser-action"
                  ];

                  vertical-tabs = [ "tabbrowser-tabs" ];
                  widget-overflow-fixed-list = [ ];
                };

                seen = [
                  "reset-pbm-toolbar-button"
                  "developer-button"
                  "screenshot-button"
                  "ublock0_raymondhill_net-browser-action"
                  "_3c078156-979c-498b-8990-85f7987dd929_-browser-action"
                  "_85860b32-02a8-431a-b2b1-40fbd64c9c69_-browser-action"
                  "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
                  "vimium-c_gdh1995_cn-browser-action"
                  "addon_darkreader_org-browser-action"
                  "_57e8684d-5ae8-47d6-93c9-f870ef0e40a3_-browser-action"
                  "_84c8edb0-65ca-43a5-bc53-0e80f41486e1_-browser-action"
                  "_7efbd09d-90ad-47fa-b91a-08c472bdf566_-browser-action"
                  "sponsorblocker_ajay_app-browser-action"
                ];
              };

              "sidebar.installed.extensions" = "{3c078156-979c-498b-8990-85f7987dd929}";
              "sidebar.main.tools" = "history,syncedtabs,bookmarks";
              "sidebar.new-sidebar.has-used" = true;
              "sidebar.revamp" = false;
              "sidebar.verticalTabs" = false;
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            };

            extensions = {
              settings = common.extensions.settings;
              force = true;
            };

            isDefault = true;

            userChrome =
              # css
              ''
                #TabsToolbar { display: none !important; }
                #sidebar-header, #sidebar-panel-header { display: none !important; }
                * { border-radius: 0px !important; }

                /* Autohide Top Toolbox */
                ${common.autohideToolboxCss}

                /* Autohide Sidebar (1px collapsed, keyboard & hover expansion) */
                ${common.autohideSidebarCss}

                /* Floating Findbar at Top */
                ${common.floatingFindbarCss}
              '';
          };
        };
      };

    cacheHome.directories = [
      ".cache/mozilla"
    ];

    persistHome.directories = [
      ".config/mozilla"
      ".mozilla"
    ];
  };

}
