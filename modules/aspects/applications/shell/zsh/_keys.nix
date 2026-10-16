# Zsh Keybindings Inspector & Television Cable Integration
{ pkgs }:
let
  zsh-list-keys-tv = pkgs.writeShellScriptBin "zsh-list-keys-tv" ''
    ${pkgs.zsh}/bin/zsh -i -c '
      for km in viins vicmd visual; do
        bindkey -M "$km" 2>/dev/null | sed "s/^/$km /"
      done
    ' | ${pkgs.gawk}/bin/awk '
      BEGIN {
        desc["autosuggest-accept"] = "Accept current autosuggestion"
        desc["fzf-history-widget"] = "Interactive command history search via fzf"
        desc["_fzf_histdb_widget"] = "Interactive SQLite command history search via fzf"
        desc["histdb-skim-widget"] = "Interactive sqlite command history search via histdb-skim"
        desc["tv-history-slim-widget"] = "Interactive command history search via television (slim layout)"
        desc["fzf-tab-complete"] = "Interactive fuzzy tab completion menu via fzf-tab"
        desc["tv-smart-autocomplete"] = "Smart path / command completion via television"
        desc["tv-shell-history"] = "Interactive shell history search via television"
        desc["tv-zsh-keys"] = "Fuzzy search zsh keybindings via television"
        desc["accept-line"] = "Execute the current command buffer"
        desc["clear-screen"] = "Clear terminal screen and redraw prompt"
        desc["vi-cmd-mode"] = "Switch to vi normal / command mode"
        desc["vi-insert"] = "Switch to vi insert mode"
        desc["vi-backward-delete-char"] = "Delete character before cursor (insert mode)"
        desc["vi-backward-kill-word"] = "Delete previous word (insert mode)"
        desc["vi-kill-line"] = "Kill entire command line buffer"
        desc["vi-forward-char"] = "Move cursor right one character"
        desc["vi-backward-char"] = "Move cursor left one character"
        desc["up-line-or-history"] = "Move cursor up or previous command in history"
        desc["down-line-or-history"] = "Move cursor down or next command in history"
        desc["self-insert"] = "Insert typed character into line buffer"
        desc["list-choices"] = "List completion choices"
        desc["list-expand"] = "Expand completion / word list"
        desc["bracketed-paste"] = "Handle terminal bracketed paste content"
        desc["undo"] = "Undo last edit"
        desc["redo"] = "Redo last undone edit"
        desc["vi-yank"] = "Yank (copy) text"
        desc["vi-delete"] = "Delete text into register"
        desc["vi-change"] = "Change (delete and enter insert mode)"
        desc["vi-put-after"] = "Paste buffer after cursor"
        desc["vi-put-before"] = "Paste buffer before cursor"
        desc["edit-command-line"] = "Open current command line in $EDITOR"
        desc["which-command"] = "Query which-command help for current command"
      }

      function decode_key(k,    clean, m) {
        clean = k
        gsub(/^"|"$/, "", clean)

        if (match(clean, /^\^([A-Z])"-"\^([A-Z])$/, m)) return "Ctrl+" m[1] ".." m[2]
        if (match(clean, /^([a-zA-Z0-9])"-"([a-zA-Z0-9])$/, m)) return m[1] ".." m[2]
        if (clean == " \"-\"~\"" || clean == " -~") return "Printable Characters"

        if (clean == "^@") return "Ctrl+Space"
        if (clean == "^ ") return "Ctrl+Space"
        if (clean == "^I") return "Tab"
        if (clean == "^M" || clean == "^J") return "Enter"
        if (clean == "^?" || clean == "^H") return "Backspace"
        if (clean == "^[") return "Escape"

        if (clean == "^[[1;5I" || clean == "\\e[1;5I") return "Ctrl+Tab (Ghostty)"
        if (clean == "^[[27;5;9~" || clean == "\\e[27;5;9~") return "Ctrl+Tab (CSI u)"
        if (clean == "^[[1;6I" || clean == "\\e[1;6I") return "Ctrl+Shift+Tab (Ghostty)"
        if (clean == "^[[27;6;9~" || clean == "\\e[27;6;9~") return "Ctrl+Shift+Tab (CSI u)"
        if (clean == "^[[Z" || clean == "\\e[Z") return "Shift+Tab"
        if (clean == "^[[27;6;114~" || clean == "\\e[27;6;114~" || clean == "^[[114;6u" || clean == "\\e[114;6u" || clean == "^[[82;6u" || clean == "\\e[82;6u") return "Ctrl+Shift+R"

        if (clean == "^[[A" || clean == "^[OA") return "Up"
        if (clean == "^[[B" || clean == "^[OB") return "Down"
        if (clean == "^[[C" || clean == "^[OC") return "Right"
        if (clean == "^[[D" || clean == "^[OD") return "Left"
        if (clean == "^[[H" || clean == "^[[1~") return "Home"
        if (clean == "^[[F" || clean == "^[[4~") return "End"
        if (clean == "^[[2~") return "Insert"
        if (clean == "^[[3~") return "Delete"
        if (clean == "^[[5~") return "PageUp"
        if (clean == "^[[6~") return "PageDown"

        if (match(clean, /^\^X\^([A-Z])$/, m)) return "Ctrl+X Ctrl+" m[1]
        if (match(clean, /^\^X(.)$/, m)) return "Ctrl+X " m[1]
        if (match(clean, /^\^\[([a-zA-Z0-9])$/, m)) return "Alt+" m[1]

        if (match(clean, /^\^([A-Z])$/, m)) return "Ctrl+" m[1]

        return clean
      }

      {
        mode = $1
        line = $0
        sub(/^[^ ]+ +/, "", line)
        if (match(line, /^("[^"]*"(-"[^"]*")?) +(.*)$/, m)) {
          raw_key = m[1]
          widget = m[3]
        } else {
          match(line, /^([^ ]+) +(.*)$/, m)
          raw_key = m[1]
          widget = m[2]
        }

        if (length(raw_key) == 0 || length(widget) == 0) next

        human = decode_key(raw_key)
        d = (widget in desc) ? desc[widget] : "ZLE widget: " widget
        printf "%s\t%s\t%s\t%s\t%s\n", human, widget, mode, raw_key, d
      }
    '
  '';

  televisionCableToml =
    # toml
    ''
      [metadata]
      name = "zsh-keys"
      description = "Fuzzy search zsh keybindings across viins, vicmd, and visual modes"
      requirements = ["zsh", "gawk"]

      [source]
      command = "${zsh-list-keys-tv}/bin/zsh-list-keys-tv"
      display = "{split:\t:0}  │  {split:\t:1}  [{split:\t:2}]"
      output = "{split:\t:1}"

      [preview]
      command = "echo -e '╭── Zsh Keybinding Details ───────────\n│ Key:         {split:\t:0}\n│ Mode / Map:  {split:\t:2}\n│ Raw Zsh:     {split:\t:3}\n╰──────────────────────────────────────\n\nWidget / Action:\n{split:\t:1}\n\nDescription:\n{split:\t:4}\n\nConfig Snippet (copy to shell.nix):\nzvm_bindkey {split:\t:2} {split:\t:3} {split:\t:1}'"

      [keybindings]
      enter = "actions:info"
      ctrl-y = "actions:copy_snippet"
      alt-y = "actions:copy_key"

      [actions.info]
      description = "Echo widget name"
      command = "echo '{split:\t:1}'"
      mode = "execute"

      [actions.copy_snippet]
      description = "Copy config snippet (zvm_bindkey ...) to clipboard"
      command = "echo -n \"zvm_bindkey {split:\t:2} {split:\t:3} {split:\t:1}\" | wl-copy"
      mode = "execute"

      [actions.copy_key]
      description = "Copy raw key to clipboard"
      command = "echo -n '{split:\t:3}' | wl-copy"
      mode = "execute"
    '';
in
{
  inherit zsh-list-keys-tv televisionCableToml;
}
