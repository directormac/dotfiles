{
  flake.homeModules.librewolf =
    {
      pkgs,
      lib,
      ...
    }:
    let
      common = import ./_common { inherit pkgs lib; };
      customAddons = common.extensions.customAddons;
    in
    {

      programs.librewolf = {
        enable = true;
        nativeMessagingHosts = common.nativeMessagingHosts;
        policies = common.policies;

        globalExtensions = [
          # Add vanilla / custom plugins here.
          {
            package = customAddons.volume-control-boost-volume;
            settings = {
              private_browsing = true;
              default_area = "navbar";
            };
          }
        ]
        # Sourced from rycee
        # https://nur.nix-community.org/repos/rycee/
        ++ (with common.extensions.rycee-firefox-addons; [

          github-file-icons
          fake-filler
          tweaks-for-youtube
          sponsorblock

          {
            package = catppuccin-mocha-mauve;
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
          {
            package = darkreader;
            settings = {
              private_browsing = true;
              default_area = "navbar";
            };
          }
          # {
          #   package = sidebery;
          #   settings = {
          #     private_browsing = true;
          #     default_area = "navbar";
          #   };
          # }
          {
            package = vimium-c;
            settings = {
              private_browsing = true;
            };
          }
          {
            package = clearurls;
            settings = {
              private_browsing = true;
            };
          }
        ]);

        profiles.default = {
          isDefault = true;

          settings = {
            # UI Customization: navbar extensions (Volume Control, Dark Reader, Sidebery)
            # and overflow menu (uBlock Origin, SponsorBlock, etc.)
            "browser.uiCustomization.state" = builtins.toJSON {
              placements = {
                widget-overflow-fixed-list = [ ];
                unified-extensions-area = [
                  "ublock0_raymondhill_net-browser-action"
                  "sponsorblocker_ajay_app-browser-action"
                  "_85860b32-02a8-431a-b2b1-40fbd64c9c69_-browser-action" # github-file-icons
                  "_74145f27-f039-47ce-a470-a662b129930a_-browser-action" # clearurls
                  "vimium-c_gdh1995_cn-browser-action"
                  "_7efbd09d-90ad-47fa-b91a-08c472bdf566_-browser-action" # fake-filler
                  "_84c8edb0-65ca-43a5-bc53-0e80f41486e1_-browser-action" # tweaks-for-youtube
                ];
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
                  "_57e8684d-5ae8-47d6-93c9-f870ef0e40a3_-browser-action" # Volume Control
                  "addon_darkreader_org-browser-action" # Dark Reader
                  "_3c078156-979c-498b-8990-85f7987dd929_-browser-action" # Sidebery
                  "alltabs-button"
                  "smartwindow-group-tabs-button"
                  "ai-window-toggle"
                ];
                toolbar-menubar = [ "menubar-items" ];
                TabsToolbar = [ ];
                vertical-tabs = [ "tabbrowser-tabs" ];
                PersonalToolbar = [ "personal-bookmarks" ];
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
              dirtyAreaCache = [
                "nav-bar"
                "TabsToolbar"
                "vertical-tabs"
                "toolbar-menubar"
                "PersonalToolbar"
                "unified-extensions-area"
              ];
              currentVersion = 26;
              newElementCount = 4;
            };

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

            # Native Sidebar & Vertical Tabs settings (matching user customization screenshot)
            "sidebar.revamp" = true;
            "sidebar.verticalTabs" = true;
            # "sidebar.visibility" = "expand-on-hover";
            "sidebar.main.tools" = "history,syncedtabs,bookmarks";
            "sidebar.installed.extensions" = "";
            "sidebar.new-sidebar.has-used" = true;
            "browser.ml.chat.enabled" = true;
            "browser.ml.chat.sidebar" = true;

            # Ensure userChrome stylesheets are loaded
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };

          extensions = {
            force = true;
            settings = {
              "vimium-c@gdh1995.cn" = {
                force = true;
                settings = common.extensions.vimiumCSettings;
              };
            }
            // common.extensions.settings;
          };

          search = common.search;

          userChrome =
            # css
            ''
              #TabsToolbar { display: none !important; }
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
}
