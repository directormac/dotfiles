# MangoHud Performance Overlay Aspect
{
  den.aspects.applications.gaming.mangohud = {
    homeManager = {
      programs.mangohud = {
        settings = {
          core_load = false;
          cpu_mhz = true;
          cpu_power = true;
          # CPU
          cpu_stats = true;
          cpu_temp = true;
          cpu_text = "CPU";
          # System
          fps = true;

          fps_limit = [
            0
            60
            144
            165
            240
          ];

          fps_limit_method = "late";
          frame_timing = true;
          frametime = true;
          gl_vsync = 1;
          gpu_core_clock = true;
          gpu_mem_clock = true;
          gpu_power = true;
          gpu_stats = true;
          gpu_temp = true;
          gpu_text = "GPU";
          no_display = true;
          present_mode = true;
          ram = true;
          show_fps_limit = true;
          # GPU
          throttling_status = true;
          toggle_fps_limit = "Shift_R+F1";
          # Keybinds
          toggle_hud = "Shift_R+F12";
          vram = true;
          vsync = 2;
        };

        enable = true;
        enableSessionWide = true;

        settingsPerApplication = {
          mpv = {
            no_display = true;
          };
        };
      };

      stylix.targets.mangohud.enable = true;
    };
  };
}
