# Go Language Aspect
{ den, ... }:
{
  den.aspects.applications.dev.lang.go = {
    homeManager =
      { config, ... }:
      {
        programs.go = {
          enable = true;
          env = {
            GOPATH = [
              "${config.home.homeDirectory}/.config/go"
            ];
          };
        };
      };

    persistHome.directories = [
      ".config/go"
    ];
  };
}
