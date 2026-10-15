# Virtualization Podman & Lazydocker Leaf Aspect
{ den, ... }:
{
  den.aspects.virtualization.podman = {
    nixos =
      { lib, pkgs, ... }:
      {
        virtualisation.podman = {
          enable = lib.mkDefault true;
          dockerCompat = true;
          dockerSocket.enable = true;
          autoPrune = {
            enable = true;
            dates = "weekly";
          };
        };

        environment.systemPackages = with pkgs; [
          podman-compose
          lazydocker
        ];
      };
  };
}
