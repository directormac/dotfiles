{
  den.default = {
    nixos = {
      services.openssh = {
        hostKeys = [
          # {
          #   type = "ed25519";
          #   path = "/etc/ssh/ssh_host_ed25519_key";
          # }
        ];
      };
    };
    homeManager.programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "super" = {
          hostname = "super.internal";
          user = "artifex";
        };
        "vmakina" = {
          hostname = "vmakina.internal";
          user = "artifex";
        };
        "mini" = {
          hostname = "mini.internal";
          user = "artifex";
        };
      };
    };
  };
}
