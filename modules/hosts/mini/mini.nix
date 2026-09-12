{__findFile, ...}: let
  hostname = "mini";
in {
  # Define host
  den.hosts.x86_64-linux.${hostname} = {
    users = {
      artifex = {};
    };
  };

  den.aspects.${hostname} = {
    includes = [
      <network/ssh>
    ];
  };
}
