# Zsh and Shell Utilities Aspect
{ core, ... }:
{
  core.shell = {
    nixos =
      { lib, ... }:
      {
        environment.pathsToLink = [ "/share/zsh" ];
        programs.zsh.enable = lib.mkDefault true;
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      {
        home.packages = with pkgs; [
          bat
          fd
          fzf
          lsd
          ripgrep
          zoxide
        ];

        programs.zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        programs.zsh = {
          autosuggestion.enable = true;
          enable = true;
          enableCompletion = true;

          history = {
            ignoreAllDups = true;

            ignorePatterns = [
              "rm *"
              "pkill *"
              "cp *"
            ];

            path = "${config.home.homeDirectory}/.zsh_history";
            size = 100000;
          };

          shellAliases = {
            "c" = "clear";
            "cat" = "bat -pp";
            "cd" = "z";
            "cda" = "zoxide add";
            "cdq" = "zoxide query";
            "cdr" = "zoxide remove";
            "ci" = "zi";
            "dotfiles" = "cd ~/.dotfiles";
            "find" = "fd";
            "grep" = "rg";
            "l" = "lsd -a";
            "less" = "bat";
            "ll" = "lsd -la";
          };

          syntaxHighlighting.enable = false;
        };
      };

    persistHome.directories = [
      ".local/share/zsh"
      ".local/share/zoxide"
    ];

    persistHome.files = [
      ".zsh_history"
    ];
  };

  den.aspects.artifex.includes = [
    core.shell
  ];

  den.aspects.nixos.includes = [
    core.shell
  ];

  den.aspects.sandbox.includes = [
    core.shell
  ];

  den.aspects.super.includes = [
    core.shell
  ];
}
