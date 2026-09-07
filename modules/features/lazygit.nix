{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.lazygit =
    {
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        self.packages.${pkgs.stdenv.hostPlatform.system}.lazygit
      ];
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      config-file = pkgs.writeText "config.yml" ''
        disableStartupPopups: true

        gui:
          tabWidth: 4
          sidePanelWidth: 0.4
          commandLogSize: 20
          border: double
          statusPanelView: allBranchesLog

          nerdFontsVersion: "3"
          # Config relating to colors and styles.
          # See https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md#color-attributes

          authorColors:
            "*": "#b4befe"

          theme:
            activeBorderColor:
              - "#cba6f7"
              - bold
            inactiveBorderColor:
              - "#a6adc8"
            searchingActiveBorderColor:
              - "#f9e2af"
            optionsTextColor:
              - "#89b4fa"
            selectedLineBgColor:
              - "#313244"
            inactiveViewSelectedLineBgColor:
              - "#6c7086"
            cherryPickedCommitFgColor:
              - "#cba6f7"
            cherryPickedCommitBgColor:
              - "#45475a"
            markedBaseCommitFgColor:
              - "#89b4fa"
            markedBaseCommitBgColor:
              - "#f9e2af"
            unstagedChangesColor:
              - "#f38ba8"
            defaultFgColor:
              - "#cdd6f4"

        notARepository: "quit"

        customCommands:
          - key: 'p'
            context: 'global'
            command: 'git pull --recurse-submodules'
            loadingText: 'Pulling with submodules'
            output: 'log'
          - key: '<c-p>'
            context: 'global'
            command: 'git pull'
            loadingText: 'Pulling remote repo'
            output: 'log'
      '';
    in
    {
      packages.lazygit = inputs.wrappers.lib.wrapPackage (
        {
          config,
          wlib,
          lib,
          ...
        }:
        {
          inherit pkgs;
          package = pkgs.lazygit;
          flags = {
            "--use-config-file" = config-file;
          };
        }
      );
    };
}
