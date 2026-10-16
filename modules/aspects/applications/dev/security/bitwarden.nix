# Bitwarden & RBW Password Manager Aspect
_:
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
          settings = {
            email = user.email or "markasena@gmail.com";
          };

          enable = true;
        };
      };

    persistHome.directories = [
      ".config/Bitwarden"
      ".config/rbw"
    ];
  };
}
