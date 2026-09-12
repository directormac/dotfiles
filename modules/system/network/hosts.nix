/**
Block black domains.
[stevenblack(https://github.com/stevenblack/hosts)]
*/
{
  den.aspects.hosts.nixos = {
    networking.stevenblack = {
      enable = true;
      block = [
        "fakenews"
        "gambling"
        "porn"
        "social"
      ];
    };
  };
}
