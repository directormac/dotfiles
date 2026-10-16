# Development Role: editors, AI agents, language runtimes, git, multiplexers, and shell tools
{ den, ... }:
{
  den.aspects.roles.dev = {
    includes = with den.aspects.applications; [
      # Editors & IDEs
      dev.editor.neovim
      dev.editor.helix
      dev.editor.vim
      # dev.editor.lazyvim
      dev.editor.doom-emacs
      dev.editor.vscode
      dev.editor.zed

      # AI Coding Agents
      dev.ai.llm-agents
      dev.ai.opencode
      dev.ai.pi
      dev.ai.antigravity
      dev.ai.copilot

      # Version Control
      dev.git.git
      dev.git.github
      dev.git.lazygit

      # Terminal Multiplexers & Session Managers
      dev.mux.tmux
      dev.mux.zellij
      dev.mux.sesh
      dev.mux.workmux
      dev.mux.herdr

      # Language Toolchains & Runtimes
      dev.lang.go
      dev.lang.rust
      dev.lang.node
      dev.lang.elixir
      dev.lang.lua
      dev.lang.nix
      dev.lang.python
      dev.lang.cc

      # Developer Networking & Security
      dev.networking.winbox
      dev.networking.wireguard
      dev.networking.mtr
      dev.networking.doggo
      dev.security.bitwarden
      dev.security.gpg
      dev.security.ssh
      dev.security.sops

      # Shell Utilities, Fuzzy Finders & File Managers
      dev.shell.direnv
      dev.shell.mise
      dev.shell.television
      dev.shell.starship
      dev.shell.zoxide
      dev.shell.fzf
      dev.shell.bat
      dev.shell.btop
      dev.shell.vivid
      dev.shell.fastfetch
      dev.shell.tealdeer
      shell.yazi
      shell.superfile
    ];
  };
}
