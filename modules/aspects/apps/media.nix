# Media & Communication: Bitwarden, MPV, Vesktop (Discord)
{
  core,
  inputs,
  lib,
  ...
}:
{
  core.media = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          bitwarden-desktop
          bitwarden-cli
          bws
          vesktop
          mpvc
        ];

        programs.mpv = {
          enable = true;
          config = {
            profile = "high-quality";
            ytdl-format = "bestvideo+bestaudio";
            cache = "yes";
            demuxer-max-bytes = "400M";
            osc = false;
            border = false;
          };
          scripts = with pkgs.mpvScripts; [
            autoload
            autosub
            sponsorblock
            thumbfast
          ];
        };

        programs.rbw = {
          enable = true;
          settings = {
            email = "markasena@gmail.com";
          };
        };
      };

    persistHome.directories = [
      ".config/Bitwarden"
      ".config/vesktop"
      ".config/mpv"
      ".config/rbw"
    ];
  };

  # Attach to workstation aspect
  core.workstation.includes = [
    core.media
  ];
}
