{ lib, pkgs, ... }: {

  programs = {
    zsh = {
      enable = true;

      # Your zsh configuration
      initExtra = ''
        export GPG_TTY="$(tty)"
        export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
        gpg-connect-agent updatestartuptty /bye > /dev/null

        eval "$(starship init zsh)"
        eval "$(zoxide init zsh)"
        eval "$(navi widget zsh)"
        eval "$(fzf --zsh)"

        export FZF_DEFAULT_OPTS=" \
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
      '';

      shellAliases = {
        ll = "ls -l";
        # ... other aliases ...

        c = "clear";
        cat = "bat";
        cd = "z";
        ci = "zi";
        du = "dust";
        find = "fd";
        ga = "git add";
        gb = "git branch";
        gc = "git commit";
        gca = "git commit -a";
        gcam = "git commit -am";
        gcm = "git commit -m";
        gd = "git diff";
        gds = "git diff --staged";
        glg = "git log --all --oneline --graph --decorate";
        gm = "git merge";
        gpl = "git pull --prune";
        gps = "git push";
        gpom = "git push";
        gpt = "tgpt";
        grep = "rg";
        gs = "git status -sb";
        home = "cd ~";
        hx = "helix";
        hxconf = "helix ~/.config/helix/config.toml";
        l = "ls -a";
        la = "ls -la";
        ls = "lsd";
        lt = "ls --tree";
        lzd = "lazydocker";
        lzg = "lazygit";
        nvimconf = "cd ~/.dotfiles/nvim/ && nvim";
        pn = "pnpm";
        px = "pnpm dlx";
        rmr = "rm -r";
        ripgrep = "rg";
        tls = "tmux ls"; # tmux session list
        tmuxconf = "nvim ~/.tmux.conf";
        top = "btop"; # top/htop alternative
        v = "nvim";
        vi = "nvim";
        wh = "which";
        y = "ya"; # exit yazi with cwd
        zshconf = "nvim ~/.zshrc";
        # alias kubectl='minikube kubectl --'
        mc = "mcli";
        dcd = "docker-compose down";
        dcu = "docker-compose up -d";
      };

    };

  };

}
