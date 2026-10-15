{ self, ... }:
{
  flake.homeModules.firefox =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      common = import ./_common { inherit pkgs lib; };
    in
    {

      programs.firefox = {
        enable = true;
        nativeMessagingHosts = common.nativeMessagingHosts;

        profiles.default = {
          isDefault = true;
          settings = {
          };

          extensions = {
            packages = common.extensions.packages;
            settings = { };
          };

          search = common.search;

          userChrome =
            # css
            ''
              #TabsToolbar { display: none !important; }
              * { border-radius: 0px !important; }
            '';
        };
      };
    };
}
