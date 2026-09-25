{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.core =
    {
      pkgs,
      config,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.system}";
    in
    {

      fonts.packages = with pkgs; [
        nerd-fonts.symbols-only
        nerd-fonts.fira-mono

        noto-fonts
        corefonts
        unifont
      ];

      environment.sessionVariables = {
        EDITOR = "vim";
      };

      environment.systemPackages = with pkgs; [

        # Common
        wget
        cifs-utils
        cm_unicode

        inotify-tools
        lshw
        nfs-utils
        ntfs3g
        p7zip
        pciutils
        sshfs
        unzip
        zip

        # Language tools
        tree-sitter

        git
        neovim
        lazygit
        github-cli

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
        sesh
        tealdeer
        television
        tmux
        vivid
        wget
        yazi
        zoxide
      ];

    };
}
