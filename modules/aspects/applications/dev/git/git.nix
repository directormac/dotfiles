# Git Aspect
_:
{
  den.aspects.applications.dev.git.git = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          git
          ghgrab
        ];

        programs.git = {
          settings = {
            alias = {
              af = "!git add $(git ls-files -m -o --exclude-standard | sk -m)";
              br = "branch";
              c = "commit -m";
              ca = "commit -am";
              co = "checkout";
              d = "diff";
              df = "!git hist | peco | awk '{print $2}' | xargs -I {} git diff {}^ {}";
              edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; nvim `f`";
              essa = "push --force";
              forgor = "commit --amend --no-edit";
              fuck = "commit --amend -m";
              graph = "log --all --decorate --graph --oneline";
              hist = ''log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
              l = "log";
              llog = ''log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
              oops = "checkout --";
              pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
              ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
              r = "rebase";
              s = "status --short";
              ss = "status";
              st = "status";
            };

            credential.helper = "store";
            init.defaultBranch = "main";
            lfs.pruneoffset = "30";
            push.autoSetupRemote = true;

            user = {
              email = "mac@mkra.dev";
              name = "Mark Asena";
            };
          };

          enable = true;

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

          lfs = {
            enable = true;
            skipSmudge = true;
          };
        };
      };

    persistHome.directories = [
      ".config/git"
    ];
  };
}
