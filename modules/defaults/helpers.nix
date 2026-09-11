{
  den.default.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      /**
      #[duf.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/du/duf/package.nix#L35)

      ##[duf](https://github.com/muesli/duf/)
      */
      duf

      # [ffmeg.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/libraries/ffmpeg/generic.nix#L1073)
      # [ffmpeg](https://www.ffmpeg.org/)
      ffmpeg

      # [tlrc.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/tl/tlrc/package.nix#L29)
      # [tlrc](https://github.com/tldr-pages/tlrc)
      tldc

      # [unzip](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/un/unzip/package.nix#L110)
      # [unzip](http://www.info-zip.org/)
      unzip

      # [watchexec.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/wa/watchexec/package.nix#L57)
      # [watchexec](https://watchexec.github.io/)
      watchexec

      # [p7zip.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/p7/p7zip/package.nix#L78)
      # [p7zip](https://github.com/p7zip-project/p7zip)
      p7zip

      # [wget.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/wg/wget/package.nix#L143)
      # [wget](https://www.gnu.org/software/wget/)
      wget

      # Others

      /**

      [sshfs.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ss/sshfs-fuse/package.nix#L77)

      [sshfs](https://github.com/libfuse/sshfs)
      */
      sshfs

      # Language tools
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

      # []()
      # []()
      file

      # []()
      # []()
      fzf

      # []()
      # []()
      killall

      # []()
      # []()
      lsd

      # [bat.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ba/bat/package.nix#L85)
      # [bat](https://github.com/sharkdp/bat)
      bat

      # [bat.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/bt/btop/package.nix)
      # [bat](https://github.com/aristocratos/btop)
      btop

      # [dust.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/compilers/chicken/5/default.nix#L53)
      # [dust](https://github.com/bootandy/dust)
      dust

      # [fx.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/fd/fd/package.nix#L52)
      # [fd](https://github.com/sharkdp/fd)
      fd

      # [vivid.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/vi/vivid/package.nix#L25)
      # [vivid](https://github.com/sharkdp/vivid)
      vivid

      # [git.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/gi/git/package.nix#L651)
      # [git](https://git-scm.com/)
      git

      # [helix.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/he/helix/package.nix#L117)
      # [helix](https://helix-editor.com/)
      helix

      # [jq.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/jq/jq/package.nix#L123)
      # [jq](https://jqlang.github.io/jq/)
      jq

      # [just.nix]()
      # [just](https://github.com/casey/just)
      just

      # [kitty.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ki/kitty/package.nix#L332)
      # [kitty](https://github.com/kovidgoyal/kitty)
      # [kitty.options](https://search.nixos.org/options?channel=unstable&query=kitty&source=home_manager&type=options)
      kitty.terminfo

      # [ripgrep.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ri/ripgrep/package.nix#L66)
      # [ripgrep](https://github.com/BurntSushi/ripgrep)
      ripgrep

      # []()
      # []()
      zoxide
    ];
  };
}
