# Bitwarden & RBW Password Manager Aspect
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
          libsecret
          libargon2
          pinentry-qt
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
      ".config/Bitwarden CLI"
      ".config/rbw"
      ".local/share/rbw"
    ];
  };
}
