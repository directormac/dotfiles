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

      imports = [

        self.nixosModules.multiplexer

        self.nixosModules.yazi
        self.nixosModules.zsh

      ];

      users.users.${config.preferences.user.name} = {
        shell = selfpkgs.zshell;
      };

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

        devenv
        secretspec

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
