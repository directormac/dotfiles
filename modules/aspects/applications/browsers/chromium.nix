# Chromium & Google Chrome Browser Leaf Aspect
{
  den.aspects.applications.browsers.chromium = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.google-chrome
        ];

        programs.chromium = {
          enable = true;

          extraOpts = {
            ExtensionSettings = {
              "dbepggeogbaibhgnhhndojpepiihcmeb" = {
                toolbar_pin = "default_unpinned";
              }; # Vimium

              "ddkjiahejlhfcafbddmgiahcphecmpfh" = {
                toolbar_pin = "default_unpinned";
              }; # uBlock Origin Lite

              "eimadpbcbfnmbkopoojfekhnkhdbieeh" = {
                toolbar_pin = "force_pinned";
              }; # Dark Reader

              "mnjggcdmjocbbbhaepdhchncahnbgone" = {
                toolbar_pin = "force_pinned";
              }; # SponsorBlock

              "nngceckbapebfimnlniiiahkandclblb" = {
                toolbar_pin = "force_pinned";
              }; # Bitwarden
            };
          };
        };
      };

    homeManager =
      { pkgs, ... }:
      let
        sharedArgs = [
          "--restore-last-session=true"
          "--enable-features=AcceleratedVideoDecodeLinuxGL"
          "--enable-zero-copy"
          "--ignore-gpu-blocklist"
          "--enable-parallel-downloading"
        ];
      in
      {
        programs.chromium = {
          commandLineArgs = sharedArgs;
          enable = true;
          package = pkgs.chromium;
        };
      };

    cacheHome.directories = [
      ".cache/chromium"
      ".cache/google-chrome"
    ];

    persistHome.directories = [
      ".config/chromium"
      ".config/google-chrome"
    ];
  };

}
