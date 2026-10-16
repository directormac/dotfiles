# Core Documentation & Man Pages Aspect
_:
{
  den.aspects.core.documentation = {
    nixos =
      { pkgs, ... }:
      {
        documentation = {
          dev.enable = true;
          doc.enable = true;
          enable = true;

          man = {
            cache.enable = true;
            enable = true;
          };
        };

        environment.systemPackages = with pkgs; [
          manix
          man-pages
          man-pages-posix
        ];
      };
  };
}
