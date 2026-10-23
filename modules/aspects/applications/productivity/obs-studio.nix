# Obs Studio
{
  den.aspects.applications.productivity.obs-studio = {
    nixos =
      { config, ... }:
      {
        boot.extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1
        '';

        # Virtual webcam output support for OBS (v4l2loopback)
        boot.extraModulePackages = [
          (config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              find $out/lib/modules -maxdepth 2 -type f ! -name "*.ko*" -delete
            '';
          }))
        ];

        boot.kernelModules = [ "v4l2loopback" ];
      };

    homeManager =
      { pkgs, ... }:
      {
        programs.obs-studio = {
          enable = true;

          plugins = with pkgs.obs-studio-plugins; [
            # Wayland & Linux Hardware Integration
            obs-pipewire-audio-capture # Isolated per-application audio capture via PipeWire
            obs-vkcapture # High-performance Vulkan/OpenGL screen & game capture
            obs-vaapi # Hardware acceleration via VA-API
            obs-gstreamer # GStreamer pipelines
            wlrobs # Direct wlroots screencopy protocol capture
            looking-glass-obs # Direct frame exchange for Looking Glass VM

            # Privacy & API Key Masking
            obs-composite-blur # Bounding-box and shape blur for credentials/prompts
            (obs-advanced-masks.overrideAttrs (old: {
              NIX_CFLAGS_COMPILE =
                (old.NIX_CFLAGS_COMPILE or "")
                + " -Wno-error=discarded-qualifiers -Wno-error=incompatible-pointer-types";
            }))
            obs-freeze-filter # Hotkey-triggered frame freeze while typing secrets
            obs-source-clone # Clone sources to crop & mask without GPU penalty
            obs-shaderfilter # Custom GLSL filters (pixelation, censor mosaics)

            # Production, Automation & Overlays
            advanced-scene-switcher # Automated scene transitions based on window title/audio
            obs-source-record # Record clean background sources while streaming overlays
            (obs-move-transition.overrideAttrs (old: {
              NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -Wno-error=deprecated-declarations";
            }))
            obs-backgroundremoval # AI virtual green-screen background removal
            obs-browser-transition # Web-based transition stingers
            input-overlay # Real-time keyboard/mouse keystroke overlay
            waveform # Audio visualizer spectrum
            obs-teleport # Zero-config network video feed over LAN
          ];
        };
      };

    persistHome.directories = [
      ".config/obs-studio"
    ];
  };
}
