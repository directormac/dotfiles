# Chromium & Google Chrome Browser Leaf Aspect
{
  den.aspects.applications.browsers.chromium = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          (pkgs.google-chrome.override {
            commandLineArgs = [
              "--password-store=gnome-libsecret"
              "--restore-last-session=true"
              "--enable-features=AcceleratedVideoDecodeLinuxGL"
              "--enable-zero-copy"
              "--ignore-gpu-blocklist"
              "--enable-parallel-downloading"
            ];
          })
        ];

        programs.chromium = {
          enable = true;

          extensions = [
            "hfjbmagddngcpeloejdejnfgbamkjaeg" # Vimium C
            "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
            "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
            "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
            "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
          ];

          extraOpts = {
            ExtensionSettings = {
              "ddkjiahejlhfcafbddmgiahcphecmpfh" = {
                installation_mode = "force_installed";
                toolbar_pin = "default_unpinned";
                update_url = "https://clients2.google.com/service/update2/crx";
              }; # uBlock Origin Lite

              "eimadpbcbfnmbkopoojfekhnkhdbieeh" = {
                installation_mode = "force_installed";
                toolbar_pin = "force_pinned";
                update_url = "https://clients2.google.com/service/update2/crx";
              }; # Dark Reader

              "hfjbmagddngcpeloejdejnfgbamkjaeg" = {
                installation_mode = "force_installed";
                toolbar_pin = "default_unpinned";
                update_url = "https://clients2.google.com/service/update2/crx";
              }; # Vimium C

              "mnjggcdmjocbbbhaepdhchncahnbgone" = {
                installation_mode = "force_installed";
                toolbar_pin = "force_pinned";
                update_url = "https://clients2.google.com/service/update2/crx";
              }; # SponsorBlock

              "nngceckbapebfimnlniiiahkandclblb" = {
                installation_mode = "force_installed";
                toolbar_pin = "force_pinned";
                update_url = "https://clients2.google.com/service/update2/crx";
              }; # Bitwarden
            };
          };
        };
      };

    homeManager =
      { pkgs, ... }:
      let
        sharedArgs = [
          "--password-store=gnome-libsecret"
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
          commandLineArgs = sharedArgs;

          extensions = [
            { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # Vimium C
            { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # uBlock Origin Lite
            { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
            { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # SponsorBlock
            { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
          ];

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
      ".pki"
    ];
  };

}
