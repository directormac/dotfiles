{
  flake.homeModules.git = { config, pkgs, ... }: {

    # GPG
    programs.gpg.enable = true;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false; # Mutes the second evaluation warning

      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          # Point directly to your Agenix symlinked private key
          identityFile = "/home/artifex/.ssh/mac_mkra_dev";
          # Disables querying the empty gpg-agent keyring for this host
          identitiesOnly = false;
        };
      };
    };

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-all;

      defaultCacheTtl = 10800;
      maxCacheTtl = 10800;

      enableSshSupport = true;
      defaultCacheTtlSsh = 10800;
      maxCacheTtlSsh = 10800;
      sshKeys = [
        "E9A28495202EB6723965F5C42E0855AA109CF7D1"
      ];

      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    # GIT
    programs.git = {
      enable = true;

      lfs = {
        enable = true;
        skipSmudge = true;
      };

      ignores = [
        "*.o"
        "*.out"
        "*.result"
        "result"
        ".env"
        "*.env"
        ".secrets/master.age"
        ".DS_Store"
        "Thumbs.db"
        "*~"
        "*.swp"
      ];

      settings = {

        user = {
          email = "mac@mkra.dev";
          name = "Mark Asena";
        };
        credential.helper = "store";

        alias = {
          essa = "push --force";
          co = "checkout";
          fuck = "commit --amend -m";
          c = "commit -m";
          ca = "commit -am";
          forgor = "commit --amend --no-edit";
          graph = "log --all --decorate --graph --oneline";
          oops = "checkout --";
          l = "log";
          r = "rebase";
          s = "status --short";
          ss = "status";
          d = "diff";
          st = "status";
          br = "branch";
          ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
          pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
          af = "!git add $(git ls-files -m -o --exclude-standard | sk -m)";
          df = "!git hist | peco | awk '{print $2}' | xargs -I {} git diff {}^ {}";
          hist = ''log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
          llog = ''log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
          edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; nvim `f`";
        };

        # gpg.program = "${pkgs.gnupg}/bin/gpg";
        # commit.gpgsign = true;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        lfs.pruneoffset = "30";

      };

    };

    programs = {
      gh = {
        enable = true;
        settings.git_protocol = "ssh";
        extensions = with pkgs; [
          gh-dash
          gh-f
          gh-s
          gh-stack
          gh-markdown-preview
        ];
      };

    };
  };
}
