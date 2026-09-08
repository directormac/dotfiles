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

    let
      current = "anime_girl_holding_tea_1080p.mp4";

      sddm-astronaut =
        (pkgs.sddm-astronaut.override {
          themeConfig = {
            HeaderTextColor = "#d5c4a1";
            Background = "Backgrounds/${current}";
          };
        }).overrideAttrs
          (oldAttrs: {
            installPhase = oldAttrs.installPhase + ''
              chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
              cp ${../../../config/wallpapers/${current}} \
                $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/${current}
            '';
          });
    in
    {
      environment.systemPackages = with pkgs; [
        sddm-astronaut
        # GStreamer is required for QtMultimedia to play video backgrounds
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav

        # Script to easily randomize the wallpaper!
        (writeShellApplication {
          name = "random-sddm-wallpaper";
          text = ''
            WALLPAPER=$(find ~/.dotfiles/config/wallpapers | sort -R | head -n 1)
            sed -i "s|current = \".*\";|current = \"$WALLPAPER\";|g" ~/.dotfiles/nixos/features/sddm/default.nix
            echo "Set SDDM wallpaper to $WALLPAPER"
            echo "Run your flake rebuild alias to apply!"
          '';
        })
      ];

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        extraPackages = with pkgs; [
          kdePackages.qtmultimedia
          kdePackages.qtsvg
          kdePackages.qtvirtualkeyboard
        ];
        theme = "sddm-astronaut-theme";
      };
    };
}
