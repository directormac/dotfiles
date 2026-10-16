# Tor Browser Leaf Aspect
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
