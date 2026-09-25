{
  inputs,
  self,
  ...
}:
{
  flake.homeModules.zen = {
    imports = [
      inputs.zen-browser.homeModules.beta
    ];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;

      profiles = {
        default = {
          # Catppuccin theme integration
          presets.catppuccin = {
            enable = true;
            flavor = "Mocha";
            accent = "Mauve";
          };

          # Privacy and performance tweaks
          presets.betterfox.enable = true;
          # presets.arkenfox.enable = true;
        };
      };
    };
  };

  flake.nixosModules.zen = { config, ... }: {
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.zen
      ];
    };
  };
}
