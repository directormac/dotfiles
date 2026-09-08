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
        # See https://github.com/Keyitdev/sddm-astronaut-theme
        (pkgs.sddm-astronaut.override {
          themeConfig = {
            Background = "Backgrounds/${current}";

            # --- Form & Layout Options ---
            # FormPosition = "left";           # "left", "center", or "right"
            # HaveFormBackground = "true";     # "true" or "false"
            # FormBackgroundColor = "#000000";
            # LoginFieldTextColor = "#ffffff";
            # LoginButtonTextColor = "#ffffff";
            # WarningColor = "#ffffff";

            # --- Clock & Date ---
            # TimeTextColor = "#ffffff";
            # DateTextColor = "#ffffff";

            #  --- Bottom Menu ---

            # SessionButtonTextColor = "#ffffff";
            # VirtualKeyboardButtonTextColor = "#ffffff";
            # SystemButtonsIconsColor = "#ffffff";

            # --- Font ---

            # Font = "Fira Mono Nerd Font";
            # FontSize = 14;

            # --- Blur & Dimming ---
            FullBlur = "false"; # "true" or "false" (Blurs the entire background)
            PartialBlur = "false"; # "true" or "false" (Blurs just behind the form)
            # Blur = "2.0";                    # Blur radius
            # BlurMax = "48";                  # Max blur radius
            # DimBackground = "0.0";           # 0.0 to 1.0 (opacity of black dimming layer)
            # DimBackgroundColor = "#000000";

            # --- Fonts ---
            # Font = "Fira Mono Nerd Font";    # Name of the font to use
            # FontSize = "";                   # E.g. "14" (leave empty for auto-sizing)

            # --- Colors ---
            HeaderTextColor = "#d5c4a1";
            # BackgroundColor = "#000000";
            # HighlightBackgroundColor = "#ffffff";
            # HighlightTextColor = "#000000";
            # HoverSystemButtonsIconsColor = "#ffffff";

            # --- Background Alignment ---
            # BackgroundHorizontalAlignment = "center"; # "left", "center", or "right"
            # BackgroundVerticalAlignment = "center";   # "top", "center", or "bottom"
            # CropBackground = "true";                  # "true" (Crop to fill) or "false" (Fit)

            # --- Video Options ---
            # PauseBackground = "false";       # "true" or "false"
            # BackgroundSpeed = "1.0";         # Playback speed for videos
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
            # Find a random file and use basename to ensure we only get the filename, not the full path
            WALLPAPER_PATH=$(find ~/.dotfiles/config/wallpapers -type f | sort -R | head -n 1)
            WALLPAPER=$(basename "$WALLPAPER_PATH")

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
