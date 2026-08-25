-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")


-- https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h

-- #define XKB_KEY_space                         0x0020  /* U+0020 SPACE */
-- #define XKB_KEY_exclam                        0x0021  /* U+0021 EXCLAMATION MARK */
-- #define XKB_KEY_quotedbl                      0x0022  /* U+0022 QUOTATION MARK */
-- #define XKB_KEY_numbersign                    0x0023  /* U+0023 NUMBER SIGN */
-- #define XKB_KEY_dollar                        0x0024  /* U+0024 DOLLAR SIGN */
-- #define XKB_KEY_percent                       0x0025  /* U+0025 PERCENT SIGN */
-- #define XKB_KEY_ampersand                     0x0026  /* U+0026 AMPERSAND */
-- #define XKB_KEY_apostrophe                    0x0027  /* U+0027 APOSTROPHE */
-- #define XKB_KEY_quoteright                    0x0027  /* deprecated */
-- #define XKB_KEY_parenleft                     0x0028  /* U+0028 LEFT PARENTHESIS */
-- #define XKB_KEY_parenright                    0x0029  /* U+0029 RIGHT PARENTHESIS */
-- #define XKB_KEY_asterisk                      0x002a  /* U+002A ASTERISK */
-- #define XKB_KEY_plus                          0x002b  /* U+002B PLUS SIGN */
-- #define XKB_KEY_comma                         0x002c  /* U+002C COMMA */
-- #define XKB_KEY_minus                         0x002d  /* U+002D HYPHEN-MINUS */
-- #define XKB_KEY_period                        0x002e  /* U+002E FULL STOP */
-- #define XKB_KEY_slash                         0x002f  /* U+002F SOLIDUS */
-- #define XKB_KEY_0                             0x0030  /* U+0030 DIGIT ZERO */
-- #define XKB_KEY_1                             0x0031  /* U+0031 DIGIT ONE */
-- #define XKB_KEY_2                             0x0032  /* U+0032 DIGIT TWO */
-- #define XKB_KEY_3                             0x0033  /* U+0033 DIGIT THREE */
-- #define XKB_KEY_4                             0x0034  /* U+0034 DIGIT FOUR */
-- #define XKB_KEY_5                             0x0035  /* U+0035 DIGIT FIVE */
-- #define XKB_KEY_6                             0x0036  /* U+0036 DIGIT SIX */
-- #define XKB_KEY_7                             0x0037  /* U+0037 DIGIT SEVEN */
-- #define XKB_KEY_8                             0x0038  /* U+0038 DIGIT EIGHT */
-- #define XKB_KEY_9                             0x0039  /* U+0039 DIGIT NINE */
-- #define XKB_KEY_colon                         0x003a  /* U+003A COLON */
-- #define XKB_KEY_semicolon                     0x003b  /* U+003B SEMICOLON */
-- #define XKB_KEY_less                          0x003c  /* U+003C LESS-THAN SIGN */
-- #define XKB_KEY_equal                         0x003d  /* U+003D EQUALS SIGN */
-- #define XKB_KEY_greater                       0x003e  /* U+003E GREATER-THAN SIGN */
-- #define XKB_KEY_question                      0x003f  /* U+003F QUESTION MARK */
-- #define XKB_KEY_at                            0x0040  /* U+0040 COMMERCIAL AT */

hl.bind("SUPER + H",  function ()
  hl.dsp.exec_cmd("omarchy-shell shell toggle io.github.chris.window-hints '{}'")
  hl.dsp.submap("hints")
end
)

hl.define_submap("hints", function()


    local function key(k)
        return hl.dsp.exec_cmd("omarchy-shell window-hints key " .. k)
    end

    for _, ch in ipairs({ "a", "s", "d", "f", "g", "h", "j", "k", "l" }) do
        hl.bind(ch, key(ch))
        hl.bind("SHIFT + " .. ch, key(string.upper(ch)))
    end

    hl.bind("x", key("x"))
    for n = 1, 9 do
        hl.bind(tostring(n), key(tostring(n)))
    end

    hl.bind("escape", function()
        hl.dispatch(key("escape"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("catchall", hl.dsp.no_op())
end)


hl.unbind("SUPER + backslash")
o.bind("SUPER + backslash", "Find everything . ","$HOME/.local/bin/omarchy-find")

-- BEGIN im0001gt.screens
hl.unbind("SUPER + SLASH")
hl.unbind("SUPER + ALT + SLASH")
o.bind("SUPER + SLASH", "Monitor scaling up", "/home/artifex/.config/omarchy/plugins/im0001gt.screens/scripts/display-ctl scale up")
o.bind("SUPER + ALT + SLASH", "Monitor scaling down", "/home/artifex/.config/omarchy/plugins/im0001gt.screens/scripts/display-ctl scale down")
-- END im0001gt.screens
