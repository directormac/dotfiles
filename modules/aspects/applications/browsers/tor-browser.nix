# Tor Browser Leaf Aspect
_:
{
  den.aspects.applications.browsers.tor-browser = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.tor-browser
        ];
      };
  };
}
