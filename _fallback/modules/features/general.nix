{
  self,
  inputs,
  ...
}:
{
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
        multiplexer
        editor

        # nightly-neovim

        nix-ld
      ];

      users.users.${config.preferences.user.name} = {
        shell = pkgs.zsh;
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
        nix-prefetch-scripts
        nix-tree
        ncdu
        btop
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
        starship
        tealdeer
        television
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
