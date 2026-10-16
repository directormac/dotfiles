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
        common = import ./_common { inherit pkgs lib; };
        customAddons = common.extensions.customAddons;
      in
      {
        programs.firefox = {
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

          inherit (common) nativeMessagingHosts;

          profiles.default = {
            extensions = {
              settings = {
                "vimium-c@gdh1995.cn" = {
                  settings = common.extensions.vimiumCSettings;
                  force = true;
                };
              }
              // common.extensions.settings;

              force = true;
            };

            isDefault = true;
            inherit (common) search;

            userChrome =
              # css
              ''
                #TabsToolbar { display: none !important; }
                * { border-radius: 0px !important; }
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
