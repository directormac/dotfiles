# Sesh Tmux Session Manager Aspect
{ den, ... }:
{
  den.aspects.applications.dev.mux.sesh = {
    nixpkgs-overlays = _: [
      (final: prev: {
        # nixpkgs builds sesh (and its go-mockery codegen tool) with Go 1.27, but
        # go-mockery 3.8.0 pins x/tools v0.49.0, which cannot read Go 1.27's export
        # data format (v5). Pin both back to Go 1.26 until upstream ships a fix.
        sesh = prev.sesh.override {
          buildGo127Module = prev.buildGo126Module;
        };
      })
    ];

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.sesh
        ];
      };

    homeManager =
      { ... }:
      {
        programs.sesh = {
          enable = true;
          enableAlias = true;

          settings = {
            wildcard = [
              {
                pattern = "~/Projects/*";
                windows = [
                  "editor"
                  "terminal"
                ];
              }
              {
                pattern = "~/Code/.worktrees/*/*";
                windows = [
                  "editor"
                  "terminal"
                  "lazygit"
                ];
              }
            ];
            session = [
              {
                name = "Dotfiles";
                path = "~/.dotfiles";
              }
              {
                name = "Config";
                path = "~/.dotfiles/config";
              }
              {
                name = "Default";
                path = "~/";
              }
            ];
            window = [
              {
                name = "editor";
                startup_script = "nvim";
              }
              {
                name = "terminal";
                startup_script = "clear";
              }
              {
                name = "lazygit";
                startup_script = "lazygit";
              }
              {
                name = "agent";
                startup_script = "agy";
              }
            ];
          };
        };
      };
  };
}
