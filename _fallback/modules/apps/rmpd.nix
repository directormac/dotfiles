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
        default_output = "pipewire"
        replay_gain = "off"

        [[output]]
        name = "PipeWire Sound Server"
        type = "pipewire"
        resampler_quality = "sinc_medium"
      '';

      systemd.user.services.rmpd = {
        Unit = {
          Description = "rmpd - Rust Music Player Daemon";
          After = [
            "network.target"
            "pipewire.service"
          ];
        };

        Service = {
          ExecStart = "${rmpdPkg}/bin/rmpd";
          Restart = "always";
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
