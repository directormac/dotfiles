# Steam Gaming Aspect
{ den, ... }:
{
  den.aspects.applications.gaming.steam = {
    nixos =
      {
        lib,
        pkgs,
        host,
        ...
      }:
      let
        hasAmd = hasAspect (den.aspects.hardware.graphics.amd or null);
        hasAspect = aspect: (host ? hasAspect) && aspect != null && host.hasAspect aspect;
        hasNvidia = hasAspect (den.aspects.hardware.graphics.nvidia or null);
        hasNvidiaPrime =
          hasAspect (den.aspects.hardware.graphics.nvidia-prime or null)
          || (hasNvidia && hasAspect (den.aspects.hardware.laptop or null));
      in
      {
        environment.systemPackages = with pkgs; [
          steam-run
          wine
          winetricks
          wineWow64Packages.staging
          wineWow64Packages.waylandFull
        ];

        hardware = {
          graphics.enable32Bit = true;
          steam-hardware.enable = true;
        };

        nix.settings = {
          substituters = [ "https://nix-gaming.cachix.org" ];
          trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
        };

        programs = {
          appimage.binfmt = true;
          appimage.enable = true;

          steam = {
            dedicatedServer.openFirewall = true;
            enable = true;

            extraCompatPackages = [
              pkgs.proton-ge-bin
            ]
            ++ lib.optionals (pkgs ? proton-cachyos-x86_64_v3) [
              pkgs.proton-cachyos-x86_64_v3
            ];

            gamescopeSession = {
              args = [
                "--rt"
                "--expose-wayland"
                "--hdr-enabled"
                "--hdr-itm-enabled"
                "--hdr-debug-force-output"
                "--xwayland-count 2"
                "-W 3840"
                "-H 2160"
                "-r 120"
              ];

              enable = true;

              env = {
                DXVK_HDR = "1";
              };
            };

            localNetworkGameTransfers.openFirewall = true;

            package = pkgs.steam.override {
              extraEnv = {
                MANGOHUD = true;
                OBS_VKCAPTURE = true;
                PROTON_ENABLE_HDR = true;
                PROTON_ENABLE_WAYLAND = true;
                PROTON_USE_NTSYNC = true;
                PROTON_USE_WOW64 = true;
                PULSE_SINK = "Game";
              }
              // lib.optionalAttrs (!hasNvidia || hasAmd) {
                RADV_TEX_ANISO = 16;
              }
              // lib.optionalAttrs hasNvidiaPrime {
                NV_PRIME_RENDER_OFFLOAD = "1";
                "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
                "__NV_PRIME_RENDER_OFFLOAD_PROVIDER" = "NVIDIA-G0";
                "__VK_LAYER_NV_optimus" = "NVIDIA_only";
              };

              extraLibraries =
                p: with p; [
                  atk
                ];

              extraPkgs =
                pkgs':
                let
                  inherit (pkgs') lib;
                  mkDeps =
                    pkgsSet: with pkgsSet; [
                      qt6.qtwayland
                      xdg-utils
                      libx11
                      libxext
                      libxrender
                      libxi
                      libxinerama
                      libxcursor
                      libxscrnsaver
                      libsm
                      libice
                      libxcb
                      libxrandr
                      libxkbcommon
                      freetype
                      fontconfig
                      glib
                      libpng
                      libpulseaudio
                      libvorbis
                      libkrb5
                      keyutils
                      libglvnd
                      libdrm
                      vulkan-tools
                      vulkan-loader
                      vulkan-validation-layers
                      vulkan-extension-layer
                      (lib.getLib stdenv.cc.cc)
                    ];
                in
                mkDeps pkgs';

              # Raw shell appended to the FHS profile. extraEnv is not usable
              # here: it goes through lib.toShellVars, which single-quotes.
              # https://vronlinux.org/docs/distros/nixos/
              extraProfile = ''
                # Without this, an XR title launched from Steam cannot see the
                # host OpenXR runtime and fails to reach Monado/WiVRn.
                export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
                # VRChat and friends otherwise misreport the timezone.
                unset TZ
              '';
            };

            protontricks.enable = true;
            remotePlay.openFirewall = true;
          };
        };

        virtualisation.vmVariant = {
          programs.steam.enable = lib.mkVMOverride false;
        };
      };

    homeManager =
      {
        lib,
        pkgs,
        host,
        ...
      }:
      let
        hasAmd = hasAspect (den.aspects.hardware.graphics.amd or null);
        hasAspect = aspect: (host ? hasAspect) && aspect != null && host.hasAspect aspect;
        hasNvidia = hasAspect (den.aspects.hardware.graphics.nvidia or null);
        hasNvidiaPrime =
          hasAspect (den.aspects.hardware.graphics.nvidia-prime or null)
          || (hasNvidia && hasAspect (den.aspects.hardware.laptop or null));
      in
      lib.mkIf (!((host ? hasAspect) && host.hasAspect den.aspects.applications.gaming.steam)) {
        home.packages = [
          (pkgs.steam.override {
            extraEnv = {
              MANGOHUD = true;
              OBS_VKCAPTURE = true;
              PROTON_ENABLE_HDR = true;
              PROTON_ENABLE_WAYLAND = true;
              PROTON_USE_NTSYNC = true;
              PROTON_USE_WOW64 = true;
              PULSE_SINK = "Game";
            }
            // lib.optionalAttrs (!hasNvidia || hasAmd) {
              RADV_TEX_ANISO = 16;
            }
            // lib.optionalAttrs hasNvidiaPrime {
              NV_PRIME_RENDER_OFFLOAD = "1";
              "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
              "__NV_PRIME_RENDER_OFFLOAD_PROVIDER" = "NVIDIA-G0";
              "__VK_LAYER_NV_optimus" = "NVIDIA_only";
            };

            extraLibraries = p: with p; [ atk ];

            extraPkgs =
              pkgs': with pkgs'; [
                qt6.qtwayland
                xdg-utils
                libx11
                libxext
                libxrender
                libxi
                libxinerama
                libxcursor
                libxscrnsaver
                libsm
                libice
                libxcb
                libxrandr
                libxkbcommon
                freetype
                fontconfig
                glib
                libpng
                libpulseaudio
                libvorbis
                libkrb5
                keyutils
                libglvnd
                libdrm
                vulkan-tools
                vulkan-loader
                vulkan-validation-layers
                vulkan-extension-layer
                (lib.getLib stdenv.cc.cc)
              ];
          })
        ];
      };

    cacheHome.directories = [
      ".local/share/Steam"
      ".steam"
    ];
  };
}
