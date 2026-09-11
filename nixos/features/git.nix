{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.git = {pkgs, ...}: {
    programs.git = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.git;
    };
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-all;
    };
  };
  perSystem = {pkgs, ...}: {
    packages.git = inputs.wrappers.wrappers.git.wrap {
      inherit pkgs;
      runtimePkgs = with pkgs; [
        git-secret
      ];
      settings = {
        user = {
          email = "mac@mkra.dev";
          name = "Mark Asena";
        };
        credential.helper = "store";
      };
    };
  };
}
