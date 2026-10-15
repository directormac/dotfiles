# Development Role: editors, AI agents, language runtimes, git, multiplexers, and shell tools
{ den, ... }:
{
  den.aspects.roles.dev = {
    includes = with den.aspects; [
      # Editors & IDEs
      applications.dev.editor.neovim
      applications.dev.editor.helix
      applications.dev.editor.vim
      # applications.dev.editor.lazyvim
      applications.dev.editor.doom-emacs
      applications.dev.editor.vscode
      applications.dev.editor.zed

      # AI Coding Agents
      applications.dev.ai.llm-agents
      applications.dev.ai.opencode
      applications.dev.ai.pi
      applications.dev.ai.antigravity
      applications.dev.ai.copilot

      # Version Control
      applications.dev.git.git
      applications.dev.git.github
      applications.dev.git.lazygit

      # Terminal Multiplexers & Session Managers
      applications.dev.mux.tmux
      applications.dev.mux.zellij
      applications.dev.mux.sesh
      applications.dev.mux.workmux
      applications.dev.mux.herdr

      # Language Toolchains & Runtimes
      applications.dev.lang.go
      applications.dev.lang.rust
      applications.dev.lang.node
      applications.dev.lang.elixir
      applications.dev.lang.lua
      applications.dev.lang.nix
      applications.dev.lang.cc

      # Developer Networking & Security
      applications.dev.networking.winbox
      applications.dev.networking.wireguard
      applications.dev.networking.mtr
      applications.dev.networking.doggo
      applications.dev.security.bitwarden
      applications.dev.security.gpg
      applications.dev.security.ssh
      applications.dev.security.sops

      # Shell Utilities, Fuzzy Finders & File Managers
      applications.dev.shell.direnv
      applications.dev.shell.mise
      applications.dev.shell.television
      applications.dev.shell.starship
      applications.dev.shell.zoxide
      applications.dev.shell.fzf
      applications.dev.shell.bat
      applications.dev.shell.btop
      applications.dev.shell.vivid
      applications.dev.shell.fastfetch
      applications.dev.shell.tealdeer
      applications.shell.yazi
      applications.shell.superfile
    ];
  };

  # Backward compatibility aliases
  den.aspects.dev.includes = [ den.aspects.roles.dev ];
}
