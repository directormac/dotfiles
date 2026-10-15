{ den, ... }:
{
  den.aspects.artifex = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      den.batteries.host-aspects
    ];

    homeManager =
      _:
      {
        home.homeDirectory = "/home/artifex";
        home.username = "artifex";
      };

    # User can provide NixOS configurations to hosts it is included on
    provides.to-hosts.nixos = _: { };
  };
}
