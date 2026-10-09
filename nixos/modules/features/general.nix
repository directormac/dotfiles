{
  self,
  inputs,
  ...
}:
{

  flake.homeModules.general = { pkgs, ... }: {

    stylix.targets = {
      btop.enable = true;
    };

    programs = {
      bat = {
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
      vivid = {
        enableZshIntegration = true;
        enableBashIntegration = true;
        activeTheme = "catppuccin-mocha";
        colorMode = "24-bit";
      };

      btop = {
        enable = true;
        package = pkgs.btop.override { rocmSupport = true; };
        settings = {
          theme_background = false;
          truecolor = true;
          force_tty = false;
          disable_presets = "Off";
          rounded_corners = false;
          vim_keys = true;
          shown_boxes = "cpu mem net proc";

          #* Define presets for the layout of the boxes. Preset 0 is always all boxes shown with default settings. Max 9 presets.
          #* Format: "box_name:P:G,box_name:P:G" P=(0 or 1) for alternate positions, G=graph symbol to use for box.
          #* Use whitespace " " as separator between different presets.
          #* Example: "cpu:0:default,mem:0:tty,proc:1:default cpu:0:braille,proc:0:tty"
          presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";

          #* Default symbols to use for graph creation, "braille", "block" or "tty".
          #* "braille" offers the highest resolution but might not be included in all fonts.
          #* "block" has half the resolution of braille but uses more common characters.
          #* "tty" uses only 3 different symbols but will work with most fonts and should work in a real TTY.
          #* Note that "tty" only has half the horizontal resolution of the other two, so will show a shorter historical view.
          graph_symbol = "braille";

        };

      };

      fzf = {
        enable = true;
        # https://github.com/junegunn/fzf/wiki/Color-schemes
        colors = { };
        enableBashIntegration = true;
        enableZshIntegration = true;
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

        # Command line options for the ALT-C keybinding.
        changeDirWidget = {
          command = "fd --type d --strip-cwd-prefix --hidden --no-ignore --follow --exclude .git";
          options = [ ];
        };

        # Command line options for the CTRL-T keybinding.
        fileWidget = {
          command = "fd --type f --strip-cwd-prefix --hidden --no-ignore --follow --exclude .git";
          options = [ ];
        };

        # The command that gets executed as the source for fzf for the CTRL-R keybinding.
        # https://search.nixos.org/options?channel=unstable&query=programs.fzf&source=home_manager&type=options
        historyWidget = {
          command = null;
          options = [
            "--layout=reverse"
            "--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
            "--color header:italic"
            "--header 'Press CTRL-Y to copy command into clipboard'"
          ];
        };

      };

      zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      superfile = {
        enable = true;
        # theme = "catppuccin-mocha";
        # package = inputs.superfile.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };

    };

  };

  flake.nixosModules.general =
    {
      pkgs,
      config,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {

      imports = with self.nixosModules; [
        inputs.nix-index-database.nixosModules.nix-index

        yazi
        zsh
        starship
        multiplexer
        tmux
        editor
        television
        tuxedo

        nix-ld
        nh
        lazygit
      ];

      users.users.${config.preferences.user.name} = {
        shell = pkgs.zsh;
      };

      home-manager.users.${config.preferences.user.name} = {
        imports = with self.homeModules; [
          general
        ];
      };

      security.sudo-rs.enable = true;

      fonts.packages = with pkgs; [
        nerd-fonts.symbols-only
        nerd-fonts.fira-mono

        noto-fonts
        corefonts
        unifont
        cm_unicode
      ];

      environment.sessionVariables = {
        EDITOR = "neovim";
      };

      programs = {
        nix-index-database.comma.enable = true;
      };

      environment.systemPackages = with pkgs; [
        # Nix
        nix-index

        # Common
        aria2
        wget
        cifs-utils
        inotify-tools
        lshw
        nfs-utils
        ntfs3g
        # Install later
        _7zip-zstd
        _7zz
        _7zz-rar
        pciutils
        sshfs
        unzip
        unrar
        zip
        doggo
        gnumake
        gcc
        binutils
        llvm
        man-pages

        # Dev tools
        jq
        yq
        git
        github-cli

        # CLI Goodies
        bat
        nix-prefetch-scripts
        nix-prefetch-github
        nix-tree
        ncdu
        dust
        fastfetch
        microfetch
        fd
        file
        fzf
        ghgrab
        smartmontools
        imv
        killall
        lsd
        ripgrep
        tealdeer
        trash-cli
        vivid
        wget
        superfile
        # inputs.superfile.packages.${pkgs.stdenv.hostPlatform.system}.default

      ];

    };
}
