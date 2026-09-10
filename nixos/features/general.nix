{ self, inputs, ... }: {
  flake.nixosModules.general =
    {
      pkgs,
      config,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.system}";
    in
    {
      imports = [
        inputs.home-manager.nixosModules.default

        self.nixosModules.nix
        self.nixosModules.git
        self.nixosModules.zsh
        self.nixosModules.lazyvim
      ];

      preferences.lazyvim.enable = true;

      fonts.packages = with pkgs; [
        nerd-fonts.symbols-only
        nerd-fonts.fira-mono

        noto-fonts
        corefonts
        unifont

        cm_unicode
        inotify-tools

        lshw
        pciutils
        cifs-utils
        nfs-utils
        ntfs3g
      ];

      environment.systemPackages = with pkgs; [

        # Others
        ffmpeg-full
        p7zip
        sshfs
        unzip
        yt-dlp
        zip

        # Language tools
        tree-sitter
        lua-language-server
        stylua

        git
        github-cli

        # CLI Goodies
        bat
        btop
        dust
        fastfetch
        imv
        fd
        file
        fzf
        killall
        lsd
        ripgrep
        vivid
        wget
        yazi
        zoxide

        television
        tealdeer
        sesh

        tmux

        # wrapped
        self.packages."${pkgs.system}".qalc
        self.packages."${pkgs.system}".nix-check-bin
        self.packages."${pkgs.system}".nh
        self.packages."${pkgs.system}".lazygit
        self.packages."${pkgs.system}".my-vim
      ];

      users.users.${config.preferences.user.name} = {
        isNormalUser = true;
        description = "${config.preferences.user.name}'s account";
        extraGroups = [
          "kvm"
          "libvirt"
          "libvirt-qemu"
          "networkmanager"
          "root"
          "wheel"
        ];
        shell = selfpkgs.environment;

        # hashedPasswordFile = "/persist/passwd";
        initialPassword = "12345";
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
        backupFileExtension = "backup";
      };

      home-manager.users.${config.preferences.user.name} =
        { config, ... }:
        let
          # Define where your flake lives on the live filesystem
          flakePath = "${config.home.homeDirectory}/.dotfiles";
        in
        {
          # Keep general for cli that can work without displays.
          home.file = {
            ".config/bat".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/bat";
            ".config/vim".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/vim";
            ".config/yazi".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/yazi";
          };
        };

      # persistance.data.directories = [
      #   ".dotfiles"
      #   "Code"
      #   "Documents"
      #   "Projects"
      #   ".ssh"
      # ];

      # persistance.cache.directories = [
      #   ".local/share/zoxide"
      #   ".local/share/direnv"
      #   ".local/share/nvim"
      #   ".local/share/fish"
      #   ".config/nvim"
      # ];
    };
}
