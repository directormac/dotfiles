# Gaming Aspect: Steam & MangoHud (Excluded inside VM variants)
{ core, lib, ... }:
{
  core.gaming = {
    nixos =
      { pkgs, lib, ... }:
      {
        programs.steam = {
          enable = lib.mkDefault true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };

        programs.gamemode.enable = lib.mkDefault true;

        virtualisation.vmVariant = {
          programs.steam.enable = lib.mkVMOverride false;
          programs.gamemode.enable = lib.mkVMOverride false;
        };
      };

    homeManager =
      { pkgs, osConfig ? null, ... }:
      let
        isVm = osConfig != null && (osConfig.virtualisation.isVM or false);
      in
      lib.mkIf (!isVm) {
        programs.mangohud = {
          enable = true;
          enableSessionWide = true;
          settings = {
            no_display = true;
            toggle_hud = "Shift_R+F12";
            fps = true;
            frametime = true;
            cpu_stats = true;
            gpu_stats = true;
            ram = true;
            vram = true;
          };
        };
      };
  };

  # Attach to workstation aspect
  core.workstation.includes = [
    core.gaming
  ];
}
