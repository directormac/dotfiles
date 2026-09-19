{den, ...}: {
  den.aspects.roles.dev = {
    includes = with den.aspects; [
      #applications.shell.nix-index
      #applications.dev.editor.nvf

      applications.dev.editor.helix

      applications.dev.security.gpg
      applications.dev.security.ssh
      applications.dev.security.bitwarden
      # applications.dev.security.ssh-agent-mux
      applications.dev.security.signing-key

      applications.dev.shell.bat
      applications.dev.shell.btop
      applications.dev.shell.direnv
      # applications.dev.shell.bottom
      # applications.dev.shell.eza
      # applications.dev.shell.starship

      applications.shell.yazi
      applications.shell.archive
      applications.shell.data
      applications.shell.disk
      applications.shell.process
      applications.shell.search
      applications.shell.zoxide

      # applications.dev.vcs.git
      # applications.dev.vcs.delta
      # applications.dev.vcs.jujutsu
      # applications.dev.vcs.mergiraf
      applications.dev.vcs.github
      applications.dev.vcs.lazygit

      applications.dev.lang.nix
      applications.dev.lang.lua
      applications.dev.lang.shell

      applications.dev.multiplexer.sesh
      applications.dev.multiplexer.tmux
    ];
  };
}
