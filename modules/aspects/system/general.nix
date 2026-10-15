# General system utilities and terminal enhancement tools
{ core, lib, ... }:
{
  core.general = {
    homeManager =
      { pkgs, ... }:
      {
        programs.bat = {
          enable = true;
          config = {
            italic-text = "always";
            map-syntax = [
              "*.ino:C++"
              ".ignore:Git Ignore"
            ];
            pager = "less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
            paging = "never";
            theme = "Catppuccin Mocha";
          };
        };

        programs.vivid = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          activeTheme = "catppuccin-mocha";
        };

        programs.btop = {
          enable = true;
          settings = {
            theme_background = false;
            truecolor = true;
            vim_keys = true;
            shown_boxes = "cpu mem net proc";
            graph_symbol = "braille";
          };
        };

        programs.fzf = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableFishIntegration = true;
          tmux.enableShellIntegration = true;
          defaultOptions = [
            "--prompt='> '"
            "--marker='>'"
            "--pointer='◆'"
            "--scrollbar='│'"
            "--gutter=' '"
            "--preview-border='line'"
            "--border='none'"
            "--separator='─'"
            "--padding='1'"
            "--highlight-line"
            "--color=fg:#CDD6F4,fg+:#CDD6F4,bg:-1,bg+:-1"
            "--color=hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,marker:#B4BEFE"
            "--color=prompt:#CBA6F7,spinner:#F5E0DC,pointer:#CBA6F7,header:#F38BA8"
            "--color=border:#6C7086,label:#CDD6F4,query:#F5E0DC"
          ];
        };

        home.packages = with pkgs; [
          fastfetch
          jq
          yq
          tealdeer
          dust
          duf
          procs
          bottom
          eza
          hyperfine
          killall
          pciutils
          usbutils
        ];
      };

    persistHome.directories = [
      ".local/share/tealdeer"
    ];
  };

  # Attach to artifex user
  den.aspects.artifex.includes = [
    core.general
  ];
}
