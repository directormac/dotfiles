# Bitwarden & RBW Password Manager Aspect
{ den, ... }:
{
  den.aspects.applications.dev.security.bitwarden = {
    homeManager =
      {
        pkgs,
        user,
        ...
      }:
      {
        home.packages = with pkgs; [
          bitwarden-desktop
          bitwarden-cli
          bws
        ];

        programs.rbw = {
          enable = true;
          settings = {
            email = user.email or "markasena@gmail.com";
          };
        };
      };

    persistHome.directories = [
      ".config/Bitwarden"
      ".config/rbw"
    ];
  };
}
