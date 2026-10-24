import QtQuick
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "desktopLyricsWidget"

    ToggleSetting {
        settingKey: "hideWhenNothingPlaying"
        label: I18n.tr("Hide When Nothing Playing")
        description: I18n.tr("Hide the widget completely when no media is playing instead of showing a placeholder")
        defaultValue: true
    }

    // ── Active Line Contrast & Readability ─────────────────────────
    SelectionSetting {
        id: pillStyleSetting
        settingKey: "activeLinePillStyle"
        label: I18n.tr("Active Line Backdrop")
        description: I18n.tr("High-contrast backdrop behind the current line for readability over any wallpaper")
        defaultValue: "pill"
        options: [
            { label: I18n.tr("Rounded Contrast Pill (Wraps text)"), value: "pill" },
            { label: I18n.tr("Full Width Card Row"),                value: "full" },
            { label: I18n.tr("None (Text Only)"),                    value: "none" }
        ]
    }

    SliderSetting {
        visible: pillStyleSetting.value !== "none"
        settingKey: "activeLinePillOpacity"
        label: I18n.tr("Active Line Backdrop Opacity")
        description: I18n.tr("Dark frosted contrast pill opacity (75% recommended for bright wallpapers)")
        defaultValue: 75
        minimum: 10
        maximum: 100
        unit: "%"
    }
    SliderSetting {
        visible: pillStyleSetting.value !== "none"
        settingKey: "activeLineBorderOpacity"
        label: I18n.tr("Active Line Border Opacity")
        description: I18n.tr("Stroke opacity of the active line contrast pill (0 = no border)")
        defaultValue: 50
        minimum: 0
        maximum: 100
        unit: "%"
    }

    ToggleSetting {
        settingKey: "textShadow"
        label: I18n.tr("High-Contrast Text Shadow")
        description: I18n.tr("Subtle drop shadow behind lyric text to ensure crisp legibility on white/bright backgrounds")
        defaultValue: true
    }

    // ── Typography & Display ───────────────────────────────────────
    SliderSetting {
        settingKey: "fontSize"
        label: I18n.tr("Font Size")
        description: I18n.tr("Size of the active lyric text in pixels")
        defaultValue: 38
        minimum: 14
        maximum: 64
        unit: "px"
    }

    SelectionSetting {
        settingKey: "lineCount"
        label: I18n.tr("Lines Shown")
        description: I18n.tr("Total lyric lines displayed around the active line")
        defaultValue: "7"
        options: [
            { label: "1", value: "1" },
            { label: "3", value: "3" },
            { label: "5", value: "5" },
            { label: "7", value: "7" }
        ]
    }

    SelectionSetting {
        settingKey: "textAlign"
        label: I18n.tr("Alignment")
        defaultValue: "center"
        options: [
            { label: I18n.tr("Left"),   value: "left"   },
            { label: I18n.tr("Center"), value: "center" },
            { label: I18n.tr("Right"),  value: "right"  }
        ]
    }

    // ── Accent Color ───────────────────────────────────────────────
    SelectionSetting {
        id: colorModeSetting
        settingKey: "colorMode"
        label: I18n.tr("Accent Color Theme")
        description: I18n.tr("Color used to highlight the currently playing line")
        defaultValue: "catppuccin"
        options: [
            { label: I18n.tr("Catppuccin Word Rainbow"), value: "catppuccin" },
            { label: I18n.tr("Catppuccin Mauve"),        value: "mauve"      },
            { label: I18n.tr("Catppuccin Pink"),         value: "pink"       },
            { label: I18n.tr("System Primary"),          value: "primary"    },
            { label: I18n.tr("System Secondary"),        value: "secondary"  },
            { label: I18n.tr("Custom Color"),            value: "custom"     }
        ]
    }

    ColorSetting {
        visible: colorModeSetting.value === "custom"
        settingKey: "customColor"
        label: I18n.tr("Custom Accent Color")
        description: I18n.tr("Used when Accent Color Theme is set to Custom")
        defaultValue: "#cba6f7"
    }

    // ── Widget Outer Card (Optional) ───────────────────────────────
    SliderSetting {
        settingKey: "backgroundOpacity"
        label: I18n.tr("Outer Widget Background Opacity")
        description: I18n.tr("Opacity of the outer container card (0 = transparent)")
        defaultValue: 0
        minimum: 0
        maximum: 100
        unit: "%"
    }

    SliderSetting {
        settingKey: "borderOpacity"
        label: I18n.tr("Outer Border Opacity")
        description: I18n.tr("Opacity of the outer card stroke")
        defaultValue: 0
        minimum: 0
        maximum: 100
        unit: "%"
    }

    SliderSetting {
        settingKey: "cardRadius"
        label: I18n.tr("Corner Radius")
        description: I18n.tr("Corner radius of the backdrop pill and widget")
        defaultValue: 20
        minimum: 0
        maximum: 40
        unit: "px"
    }
}
