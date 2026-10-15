# Core Documentation & Man Pages Aspect
{ den, ... }:
{
  den.aspects.core.documentation = {
    nixos =
      { pkgs, ... }:
      {
        documentation = {
          enable = true;
          doc.enable = true;
          dev.enable = true;
          man = {
            enable = true;
            cache.enable = true;
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
