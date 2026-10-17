# Cliphist Wayland Clipboard History Leaf Aspect
{
  den.aspects.applications.wayland.cliphist = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          cliphist
          wl-clip-persist
          wl-clipboard
        ];
      };

    homeManager =
      { pkgs, ... }:
      let
        tv-cliphist-preview = pkgs.writeShellScript "tv-cliphist-preview" ''
          item="$1"
          echo -e "╭── Clipboard Entry ─────────────────────────────"
          echo "$item" | ${pkgs.cliphist}/bin/cliphist decode 2>/dev/null | head -n 40
          echo -e "╰────────────────────────────────────────────────"
        '';
      in
      {
        xdg.configFile."television/cable/cliphist.toml".text =
          # toml
          ''
            [metadata]
            name = "cliphist"
            description = "Fuzzy search and paste from Wayland clipboard history"
            requirements = ["cliphist", "wl-copy"]

            [source]
            command = "cliphist list"
            display = "{split:\t:1..}"

            [preview]
            command = "${tv-cliphist-preview} '{}'"

            [keybindings]
            enter = "actions:copy"
            ctrl-y = "actions:copy"
            ctrl-d = "actions:delete"
            ctrl-w = "actions:wipe"

            [actions.copy]
            description = "Copy selected item to system clipboard"
            command = "echo '{}' | cliphist decode | wl-copy"
            mode = "execute"

            [actions.delete]
            description = "Delete item from clipboard history"
            command = "echo '{}' | cliphist delete"
            mode = "execute"

            [actions.wipe]
            description = "Wipe entire clipboard history"
            command = "cliphist wipe"
            mode = "execute"
          '';
      };
  };
}
