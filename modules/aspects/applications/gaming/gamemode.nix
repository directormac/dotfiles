# GameMode Performance Optimizer Aspect
{
  den.aspects.applications.gaming.gamemode = {
    nixos =
      { pkgs, ... }:
      {
        programs.gamemode = {
          enable = true;

          settings = {
            custom = {
              end = "${pkgs.writeShellScript "gamemode-end" ''
                # 1. Restore standard Hyprland keybinds
                ${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.submap("reset")' || true

                # 2. Restore DMS notifications & idle
                if command -v dms >/dev/null 2>&1; then
                  dms ipc call notifications disableDoNotDisturb || true
                  dms ipc call inhibit disable || true
                fi

                # 3. Compositor notification confirmation
                ${pkgs.hyprland}/bin/hyprctl notify 1 2500 "rgb(cba6f7)" "GameMode: ended (shortcuts restored)" || true
              ''}";

              start = "${pkgs.writeShellScript "gamemode-start" ''
                # 1. Switch Hyprland to gamemode submap (disables all binds & mouse dragging)
                ${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.submap("gamemode")' || true

                # 2. Silence DMS notifications & inhibit idle
                if command -v dms >/dev/null 2>&1; then
                  dms ipc call notifications enableDoNotDisturbIndefinitely || true
                  dms ipc call inhibit enable || true
                fi

                # 3. Compositor notification confirmation
                ${pkgs.hyprland}/bin/hyprctl notify 5 2500 "rgb(a6e3a1)" "GameMode: active (shortcuts & popups isolated)" || true
              ''}";
            };

            general = {
              renice = 10;
            };
          };
        };
      };
  };
}
