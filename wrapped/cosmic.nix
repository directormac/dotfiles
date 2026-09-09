{
  inputs,
  self,
  ...
}:
{
  flake.nixosModules.cosmic = { pkgs, lib, ... }: {
    services.desktopManager.cosmic.enable = true;
    # services.displayManager.cosmic-greeter.enable = true;
    services.displayManager.sddm.enable = true;

    environment.cosmic.excludePackages = with pkgs; [
      cosmic-edit
      cosmic-term
      cosmic-files
    ];

    # Override the cosmic-session package with our wrapped version
    nixpkgs.overlays = [
      (final: prev: {
        cosmic-session = self.packages.${pkgs.stdenv.hostPlatform.system}.cosmic;
      })
    ];
  };

  perSystem = { pkgs, self', ... }: {
    packages.cosmic = inputs.lwrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.cosmic-session;

    };
  };
}
