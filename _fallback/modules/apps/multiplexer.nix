{ inputs, self, ... }: {
  flake.homeModules.multiplexer = { pkgs, ... }: {

    home.packages = [ inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default ];

    xdg.configFile."workmux/config.yaml".text = ''
      merge_strategy: rebase
      # agent: claude
      # panes:
      #   - command: <agent>
      #     focus: true
      #   - split: horizontal
    '';
  };

  flake.nixosModules.multiplexer = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.multiplexer
      ];
    };

    environment.systemPackages = with pkgs; [
      inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
      zellij
      tmux
    ];

  };

}
