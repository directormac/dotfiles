# RMPD (Rust Music Player Daemon) & RMPC Leaf Aspect
_:
{
  den.aspects.applications.media.rmpd = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.rmpc
        ]
        ++ (lib.optionals (pkgs ? local && pkgs.local ? rmpd) [
          pkgs.local.rmpd
        ]);
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        rmpdPkg = pkgs.local.rmpd;
      in
      {
        home.packages = [
          rmpdPkg
          pkgs.rmpc
        ];

        services.mpdris2.enable = false;

        systemd.user.services.rmpd = {
          Install.WantedBy = [ "default.target" ];

          Service = {
            ExecStart = "${rmpdPkg}/bin/rmpd";
            Restart = "on-failure";
            RestartSec = "3s";
            StateDirectory = "rmpd";
          };

          Unit = {
            After = [
              "network.target"
              "sound.target"
              "pipewire.service"
              "wireplumber.service"
            ];

            Description = "rmpd - Rust Music Player Daemon";

            Wants = [
              "pipewire.service"
              "wireplumber.service"
            ];
          };
        };

        xdg.configFile."rmpd/rmpd.toml".text = ''
          [general]
          music_directory = "${config.home.homeDirectory}/Music"
          state_file = "${config.home.homeDirectory}/.local/state/rmpd/state"
          log_level = "info"

          [network]
          port = 6600
          mpris = true

          [audio]
          default_output = "PipeWire Sound Server"
          replay_gain = "off"
          restore_paused = true

          [[output]]
          name = "PipeWire Sound Server"
          type = "pipewire"
          enabled = true
          resampler_quality = "sinc_medium"
        '';
      };

    persistHome.directories = [
      ".local/state/rmpd"
    ];
  };
}
