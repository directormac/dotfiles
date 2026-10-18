{
  den.aspects.applications.dev.shell.mermaid = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.mermaid-cli
        ];
      };
  };
}
