{
  den.aspects.applications.dev.shell.mdcat = {
    homeManager =
      { pkgs, ... }:
      let
        lessiPkg = pkgs.local.lessi or pkgs.lessi;
      in
      {
        home.packages = [
          pkgs.mdcat
          lessiPkg
        ];

        home.sessionVariables = {
          MDCAT_PAGER = "lessi -F";
        };
      };
  };
}
