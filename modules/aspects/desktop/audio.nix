# Desktop Low-Latency PipeWire Audio Leaf Aspect
{
  den.aspects.desktop.audio = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.pavucontrol
        ];

        services = {
          pipewire = {
            enable = lib.mkDefault true;
            alsa.enable = true;
            alsa.support32Bit = true;

            extraConfig.pipewire."92-low-latency" = {
              "context.properties" = {
                "default.clock.allowed-rates" = [
                  44100
                  48000
                  88200
                  96000
                  176400
                  192000
                  352800
                  384000
                ];

                "default.clock.max-quantum" = 2048;
                "default.clock.min-quantum" = 32;
                "default.clock.quantum" = 512;
                "default.clock.rate" = 44100;
              };
            };

            extraConfig.pipewire-pulse."92-low-latency" = {
              context.modules = [
                {
                  args = {
                    "pulse.default.req" = "512/44100";
                    "pulse.max.quantum" = "2048/44100";
                    "pulse.max.req" = "2048/44100";
                    "pulse.min.quantum" = "32/44100";
                    "pulse.min.req" = "32/44100";
                  };

                  name = "libpipewire-module-protocol-pulse";
                }
              ];
            };

            jack.enable = true;
            pulse.enable = true;
          };

          pulseaudio.enable = false;
        };
      };

    persistHome.directories = [
      ".local/state/wireplumber"
    ];
  };
}
