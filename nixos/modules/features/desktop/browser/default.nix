{ self, ... }:
{
  flake.homeModules.browser =
    { ... }:
    {
      imports = [
        self.homeModules.zen-browser
        self.homeModules.firefox
      ];
    };

  flake.nixosModules.browser =
    { config, ... }:
    {
      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.browser
        ];
      };
    };
}
