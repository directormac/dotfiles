# Heroic Games Launcher Aspect
#
# --- Troubleshooting Sideloaded / Repack / Steam-Emulated Games ---
#
# 1. Proton Steam & DLL Hijack Overrides:
#    Proton ships with a built-in `lsteamclient.dll` that redirects Steam API calls to a
#    running native Linux Steam client. If Steam is not running or doesn't own the game,
#    calls fail ("GAME -- unable to initialize steam") and the game crashes at network init.
#    Furthermore, cracks like RUNE hook secondary DLLs (e.g., `amd_ags_x64.dll` -> `amd_ags_x64_rne.dll`
#    for AoE IV Xbox anti-cheat/license bypass), which Proton overrides with built-in stubs.
#
#    Fix (set in Game Settings -> Environment Variables or GamesConfig JSON):
#      Key:   WINEDLLOVERRIDES
#      Value: lsteamclient=d;steamclient64=n;amd_ags_x64=n
#
#    Or write directly into the Wine prefix (<prefix>/user.reg):
#      [Software\\Wine\\DllOverrides]
#      "lsteamclient"=""
#      "steamclient64"="native"
#      "amd_ags_x64"="native"
#
# 2. Goldberg Steam Emulator:
#    Nixpkgs `goldberg-emu` only supplies Linux binaries/tools (e.g. lobby_connect).
#    For Windows games in Wine/Proton, Goldberg is applied per-game by replacing
#    `steam_api64.dll` with Goldberg's Windows x64 build and placing `steam_appid.txt`
#    next to it. Even with Goldberg, `lsteamclient=d` is required under Proton.
#
# 3. Sharing Titles with Lutris (Zero Duplication):
#    To run the same install in Lutris without reinstalling:
#      - Runner: Wine
#      - Wine prefix: /mnt/local/games/heroic/Prefixes/<Game>
#      - Executable:  /mnt/local/games/heroic/Prefixes/<Game>/drive_c/Games/<Game>/<Game.exe>
#      - Working dir: /mnt/local/games/heroic/Prefixes/<Game>/drive_c/Games/<Game>
#    Because `user.reg` and `drive_c` are in the prefix, both launchers share the exact
#    same files, save states, and DLL overrides without duplicating disk space.
{
  den.aspects.applications.gaming.heroic = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.heroic
        ];
      };

    persistHome.directories = [
      ".config/heroic"
    ];
  };
}
