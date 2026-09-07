{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.sddm =
    {
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = [
        (pkgs.catppuccin-sddm.override {
          flavor = "mocha";
          font = "Fira Mono Nerd Font";
          fontSize = "14";
          background = null;
        })
      ];
      services.displayManager.sddm = {
        enable = true;
        theme = "catppuccin-mocha-mauve";
        package = pkgs.kdePackages.sddm;
      };
    };
}
