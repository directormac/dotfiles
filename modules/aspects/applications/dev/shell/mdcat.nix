{
  den.aspects.applications.dev.shell.mdcat = {
    homeManager =
      { pkgs, ... }:
      let
        mdpick = pkgs.runCommand "mdpick" { } ''
          mkdir -p $out/bin
          ln -s ${pkgs.mdcat}/bin/mdcat $out/bin/mdpick
        '';
      in
      {
        home.packages = with pkgs; [
          mdcat
          mdpick
        ];
      };
  };
}
