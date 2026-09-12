{
  # den.aspects.artifex.provides.to-hosts.homeManager.programs.git = {
  #   enable = true;
  #
  #   signing = {
  #     format = "ssh";
  #     key = "~/.ssh/id_ed25519.pub";
  #     signByDefault = true;
  #   };
  #   settings = {
  #     user.name = "Mark Kendrick Asena";
  #     user.email = "mac@mkra.dev";
  #     init.defaultBranch = "main";
  #     pull.rebase = true;
  #     push.default = "upstream";
  #     # credential."https://github.com.com" = {
  #     #   helper = "";
  #     # };
  #   };
  # };

  den.aspects = {
    artifex = {
      provides.to-hosts.homeManager.programs = {
        /**
        [git.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/gi/git/package.nix#L651)
        [git](https://git-scm.com/docs)

        ```sh
        man git

        manix git
        ```
        */
        git = {
          enable = true;
          signing = {
            format = "ssh";
            key = "~/.ssh/id_ed25519.pub";
            signByDefault = true;
          };
          settings = {
            user.name = "Mark Kendrick Asena";
            user.email = "mac@mkra.dev";
            init.defaultBranch = "main";
            pull.rebase = true;
            push.default = "upstream";
            # credential."https://github.com.com" = {
            #   helper = "";
            # };
          };
        };

        /**

        [gh.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/gh.nix#L15)

        [gh](https://docs.github.com/en/github-cli)

        */
        gh = {
          enable = true;
          hosts = {
            "github.com" = {
              user = "directormac";
            };
          };
          settings = {
            git_protocol = "ssh";
          };
        };
      };
    };
  };
}
