{ self, ... }: {
  perSystem =
    { pkgs, ... }:
    {
      packages.rmpd = pkgs.callPackage ../../pkgs/rmpd.nix { };
    };

  flake.homeModules.rmpd =
    { config, pkgs, ... }:
    let
      rmpdPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.rmpd;
    in
    {
      home.packages = [ rmpdPkg ];

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

      systemd.user.services.rmpd = {
        Unit = {
          Description = "rmpd - Rust Music Player Daemon";
          After = [
            "network.target"
            "sound.target"
            "pipewire.service"
            "wireplumber.service"
          ];
          Wants = [
            "pipewire.service"
            "wireplumber.service"
          ];
        };

        Service = {
          ExecStart = "${rmpdPkg}/bin/rmpd";
          Restart = "on-failure";
          RestartSec = "3s";
          StateDirectory = "rmpd";
        };

        Install.WantedBy = [ "default.target" ];
      };

      # rmpd handles MPRIS natively
      services.mpdris2.enable = false;
    };

  flake.nixosModules.rmpd =
    { config, ... }:
    {
      home-manager.users.${config.preferences.user.name} = {
        imports = with self.homeModules; [
          rmpd
        ];
      };
    };
}
