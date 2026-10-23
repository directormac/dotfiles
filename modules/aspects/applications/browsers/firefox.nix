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
              ".config/mozilla/firefox/default"
              ".mozilla/firefox/default"
            ];
          }
        );

        programs.firefox = {
          inherit (common) nativeMessagingHosts policies;
          enable = true;

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
