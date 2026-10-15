# MangoHud Performance Overlay Aspect
{ den, ... }:
{
  den.aspects.applications.gaming.mangohud = {
    homeManager =
      { ... }:
      {
        stylix.targets.mangohud.enable = true;

        programs.mangohud = {
          enable = true;
          enableSessionWide = true;
          settingsPerApplication = {
            mpv = {
              no_display = true;
            };
          };
          settings = {
            no_display = true;
            fps_limit = [
              0
              60
              144
              165
              240
            ];
            fps_limit_method = "late";
            vsync = 2;
            gl_vsync = 1;

            # Keybinds
            toggle_hud = "Shift_R+F12";
            toggle_fps_limit = "Shift_R+F1";

            # System
            fps = true;
            show_fps_limit = true;
            frametime = true;
            frame_timing = true;
            present_mode = true;
            core_load = false;
            ram = true;

            # CPU
            cpu_stats = true;
            cpu_temp = true;
            cpu_power = true;
            cpu_text = "CPU";
            cpu_mhz = true;

            # GPU
            throttling_status = true;
            gpu_stats = true;
            gpu_temp = true;
            gpu_core_clock = true;
            gpu_mem_clock = true;
            gpu_power = true;
            gpu_text = "GPU";
            vram = true;
          };
        };
      };
  };
}
