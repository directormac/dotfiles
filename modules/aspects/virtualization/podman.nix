# Virtualization Podman & Lazydocker Leaf Aspect
_:
{
  den.aspects.virtualization.podman = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          podman-compose
          lazydocker
        ];

        virtualisation.podman = {
          autoPrune = {
            dates = "weekly";
            enable = true;
          };

          dockerCompat = true;
          dockerSocket.enable = true;
          enable = lib.mkDefault true;
        };
      };
  };
}
