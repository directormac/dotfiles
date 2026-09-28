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

        nightly-neovim
        nix-ld
        multiplexer
        opencode

        yazi
        zsh

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
        EDITOR = "lvim";
      };

      environment.systemPackages = with pkgs; [
        # Nix
        nix-index
        inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien

        # Common
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
        zip

        # Dev tools
        tree-sitter
        git
        github-cli

        vim
        neovim

        # CLI Goodies

        bat
        btop
        dust
        fastfetch
        fd
        file
        fzf
        ghgrab
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

        selfpkgs.nh
        selfpkgs.yazi
        selfpkgs.lazygit
      ];

    };
}
