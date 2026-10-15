# WinBox MikroTik Router Administration Aspect
{ den, ... }:
{
  den.aspects.applications.dev.networking.winbox = {
    nixos =
      { pkgs, ... }:
      {
        programs.winbox = {
          enable = true;
          openFirewall = true;

          package = pkgs.winbox.overrideAttrs (oldAttrs: {
            nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

            postInstall = (oldAttrs.postInstall or "") + ''
              wrapProgram $out/bin/WinBox \
                --set QT_QPA_PLATFORM xcb
            '';
          });
        };
      };
  };
}
