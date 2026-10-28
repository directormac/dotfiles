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
                # Restore DMS notifications & idle (Hyprland submap is managed per-window in rules.lua)
                if command -v dms >/dev/null 2>&1; then
                  dms ipc call notifications disableDoNotDisturb || true
                  dms ipc call inhibit disable || true
                fi
              ''}";

              start = "${pkgs.writeShellScript "gamemode-start" ''
                # Silence DMS notifications & inhibit idle (Hyprland submap is managed per-window in rules.lua)
                if command -v dms >/dev/null 2>&1; then
                  dms ipc call notifications enableDoNotDisturbIndefinitely || true
                  dms ipc call inhibit enable || true
                fi
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
