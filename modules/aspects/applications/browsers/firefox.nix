# Firefox Browser Leaf Aspect
{
  core,
  den,
  inputs,
  lib,
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
        pkgs,
        lib,
        ...
      }:
      let
        common = import ./_common { inherit pkgs lib; };
        customAddons = common.extensions.customAddons;
      in
      {
        programs.firefox = {
          enable = true;
          nativeMessagingHosts = common.nativeMessagingHosts;

          globalExtensions = [
            {
              package = customAddons.volume-control-boost-volume;
              settings = {
                private_browsing = true;
              };
            }
          ]
          ++ (with common.extensions.rycee-firefox-addons; [
            catppuccin-mocha-mauve
            github-file-icons
            fake-filler
            tweaks-for-youtube
            sponsorblock
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
              };
            }
            {
              package = sidebery;
              settings = {
                private_browsing = true;
              };
            }
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
              '';
          };
        };
      };

    persistHome.directories = [
      ".mozilla/firefox"
    ];

    cacheHome.directories = [
      ".cache/mozilla"
    ];
  };

}
