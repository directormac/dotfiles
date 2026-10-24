# Collie PWA Mobile AI Terminal Bridge Aspect
{
  inputs,
  ...
}:
{
  den.aspects.applications.dev.ai.collie = {
    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        collieVoxtypeStt = pkgs.writeShellScriptBin "collie-voxtype-stt" ''
          set -euo pipefail

          INPUT="''${1:-}"
          if [ -z "$INPUT" ] || [ ! -f "$INPUT" ]; then
            exit 0
          fi

          # Fast silence detection: if mean volume is below -50.0 dB, treat as silence
          MEAN_VOL=$(${pkgs.ffmpeg}/bin/ffmpeg -v info -i "$INPUT" -af "volumedetect" -vn -sn -dn -f null /dev/null 2>&1 | ${pkgs.gawk}/bin/awk '/mean_volume:/ {print $5}')
          if [ -n "$MEAN_VOL" ]; then
            IS_SILENT=$(${pkgs.gawk}/bin/awk -v vol="$MEAN_VOL" 'BEGIN {print (vol < -50.0) ? 1 : 0}')
            if [ "$IS_SILENT" -eq 1 ]; then
              exit 0
            fi
          fi

          TMP_WAV=$(mktemp /tmp/collie-stt-XXXXXX.wav)
          trap 'rm -f "$TMP_WAV"' EXIT

          ${pkgs.ffmpeg}/bin/ffmpeg -v error -y -i "$INPUT" -ar 16000 -ac 1 -c:a pcm_s16le -f wav "$TMP_WAV"

          VOXTYPE_BIN="${if voxtypePkg != null then "${voxtypePkg}/bin/voxtype" else "voxtype"}"
          if ! [ -x "$VOXTYPE_BIN" ] && command -v voxtype >/dev/null 2>&1; then
            VOXTYPE_BIN=$(command -v voxtype)
          fi

          "$VOXTYPE_BIN" -q transcribe "$TMP_WAV" 2>/dev/null \
            | ${pkgs.gnugrep}/bin/grep -v -E '^(Loading audio file:|Audio format:|Processing [0-9]+ samples)' \
            | ${pkgs.gnused}/bin/sed -e '/^[[:space:]]*$/d' || true
        '';
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
        voxtypePkg = llmPkgs.voxtype or (pkgs.voxtype or null);
      in
      {
        home.file = {
          ".collie/config.toml".source = config.lib.dots.link "collie/config.toml";

          ".config/herdr/plugins/config/herdr.collie/.env".text = ''
            COLLIE_MUX=herdr
            COLLIE_HOST=0.0.0.0
            COLLIE_ALLOW_NON_LOOPBACK_BIND=true
            COLLIE_ALLOW_ANY_HOST=true
          '';

          ".config/herdr/plugins/config/herdr.collie/config.toml".source =
            config.lib.dots.link "collie/config.toml";

          ".local/bin/collie-voxtype-stt".source = "${collieVoxtypeStt}/bin/collie-voxtype-stt";
        };

        home.packages = [
          pkgs.collie
          collieVoxtypeStt
        ];

        xdg.configFile."collie".source = config.lib.dots.link "collie";
      };

    persistHome.directories = [
      ".config/collie"
      ".local/state/collie"
      ".collie"
    ];
  };
}
