# Web Browsers Aspect: Firefox, Chromium, Zen Browser
{
  core,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  core.browser = {
    nixos =
      { pkgs, ... }:
      {
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
      {
        config,
        pkgs,
        lib,
        ...
      }:
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
        imports = lib.optionals (inputs ? zen-browser) [
          inputs.zen-browser.homeModules.beta
        ];

        programs.firefox = {
          enable = true;
          policies = {
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
            EnableTrackingProtection = {
              Value = true;
              Locked = true;
              Cryptomining = true;
              Fingerprinting = true;
            };
          };
        };

        programs.chromium = {
          enable = true;
          package = pkgs.chromium;
          commandLineArgs = sharedArgs;
        };

        programs.zen-browser = lib.mkIf (inputs ? zen-browser) {
          enable = true;
          setAsDefaultBrowser = true;
          env = {
            MOZ_ENABLE_WAYLAND = "1";
          };
        };
      };

    persistHome.directories = [
      ".mozilla/firefox"
      ".zen"
      ".config/chromium"
      ".config/google-chrome"
    ];

    cacheHome.directories = [
      ".cache/mozilla"
      ".cache/zen"
      ".cache/chromium"
      ".cache/google-chrome"
    ];
  };

  # Attach to workstation aspect
  core.workstation.includes = [
    core.browser
  ];
}
