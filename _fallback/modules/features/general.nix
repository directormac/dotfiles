{
  self,
  inputs,
  ...
}:
{

  flake.homeModules.general = { ... }: {

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
        settings = {
          theme_background = false;
          truecolor = true;
          force_tty = false;
          graph_symbol = "tty";
          disable_presets = "Off";
          rounded_corners = false;
          vim_keys = true;
        };

      };

      television = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
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
          command = "fd --type d";
          options = [
            "--strip-cwd-prefix"
            "--hidden"
            "--no-ignore"
            "--follow"
            "--exclude .git"
          ];
        };

        # Command line options for the CTRL-T keybinding.
        fileWidget = {
          command = "fd --type f";
          options = [
            "--strip-cwd-prefix"
            "--hidden"
            "--no-ignore"
            "--follow"
            "--exclude .git"
          ];
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
        editor

        # nightly-neovim

        nix-ld
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
        inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien

        # Common
        aria2
        wget
        cifs-utils
        inotify-tools
        lshw
        nfs-utils
        ntfs3g
        p7zip
        pciutils
        sshfs
        unzip
        unrar
        zip
        doggo

        # Dev tools
        jq
        git
        github-cli

        # CLI Goodies
        bat
        btop
        nix-prefetch-scripts
        nix-search-tv
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
        television
        trash-cli
        vivid
        wget
        zoxide
        superfile

        selfpkgs.nh
        selfpkgs.yazi
        selfpkgs.lazygit
      ];

    };
}
