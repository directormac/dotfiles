{inputs, pkgs, ...}:{
 
 porgrams.hyprland = {
   enable = true;
   package = inputs.hyprland.packages.${pkgs.stdevent.hostPlatform.system}.hyprland

   portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop=poral-hyprland;

 };

}
