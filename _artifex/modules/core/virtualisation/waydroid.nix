{
  core.waydroid = {
    nixos = { pkgs, ... }: {
      #https://nixos.org/wiki/Podman
      environment = {
        systemPackages = with pkgs; [
          waydroid-helper
        ];
      };

      virtualisation.waydroid = {
        enable = true;
      };
    };
  };
}
