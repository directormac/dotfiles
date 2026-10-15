# Chromium & Google Chrome Browser Leaf Aspect
{
  core,
  den,
  ...
}:
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
              "ddkjiahejlhfcafbddmgiahcphecmpfh" = {
                toolbar_pin = "default_unpinned";
              }; # uBlock Origin Lite
              "dbepggeogbaibhgnhhndojpepiihcmeb" = {
                toolbar_pin = "default_unpinned";
              }; # Vimium
              "eimadpbcbfnmbkopoojfekhnkhdbieeh" = {
                toolbar_pin = "force_pinned";
              }; # Dark Reader
              "nngceckbapebfimnlniiiahkandclblb" = {
                toolbar_pin = "force_pinned";
              }; # Bitwarden
              "mnjggcdmjocbbbhaepdhchncahnbgone" = {
                toolbar_pin = "force_pinned";
              }; # SponsorBlock
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
          enable = true;
          package = pkgs.chromium;
          commandLineArgs = sharedArgs;
        };
      };

    persistHome.directories = [
      ".config/chromium"
      ".config/google-chrome"
    ];

    cacheHome.directories = [
      ".cache/chromium"
      ".cache/google-chrome"
    ];
  };

}
