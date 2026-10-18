{
  den.aspects.applications.dev.shell.mdv = {
    homeManager =
      { pkgs, ... }:
      let
        mdvPkg = pkgs.local.mdv or pkgs.mdv;
      in
      {
        home.packages = [
          mdvPkg
          (mdvPkg.mermaid-cli or pkgs.mermaid-cli)
        ];
      };

    cacheHome.directories = [
      ".cache/mdv"
    ];
  };
}
