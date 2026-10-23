import QtQuick
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "desktopAudioVisualizer"

    // ── Visualisation Mode ─────────────────────────────────────────
    SelectionSetting {
        id: vizModeSetting
        settingKey:   "vizMode"
        label:        I18n.tr("Visualisation Mode")
        defaultValue: "bars"
        options: [
            { label: I18n.tr("Bars"),          value: "bars"          },
            { label: I18n.tr("Curve Outline"), value: "curve-outline" },
            { label: I18n.tr("Curve Filled"),  value: "curve-filled"  }
        ]
    }

    // ── Color Theme & Multi-color Palette ──────────────────────────
    SelectionSetting {
        id: colorSetting
        settingKey:   "colorChoice"
        label:        I18n.tr("Color Palette")
        description:  I18n.tr("Color scheme for visualizer bars and curves")
        defaultValue: "catppuccin"
        options: [
            { label: I18n.tr("Catppuccin Full Palette (14 colors)"), value: "catppuccin"    },
            { label: I18n.tr("Theme Multi-color Rainbow"),            value: "theme-palette" },
            { label: I18n.tr("Primary to Secondary Gradient"),        value: "gradient"      },
            { label: I18n.tr("System Primary"),                       value: "primary"       },
            { label: I18n.tr("System Secondary"),                     value: "secondary"     },
            { label: I18n.tr("Surface Variant"),                      value: "surface"       }
        ]
    }

    // ── Bars Layout ────────────────────────────────────────────────
    SliderSetting {
        visible:      vizModeSetting.value === "bars"
        settingKey:   "barCount"
        label:        I18n.tr("Bar Count")
        description:  I18n.tr("Number of frequency bars across the widget")
        defaultValue: 73
        minimum:      4
        maximum:      128
    }

    SliderSetting {
        visible:      vizModeSetting.value === "bars"
        settingKey:   "barSpacing"
        label:        I18n.tr("Bar Spacing")
        defaultValue: 0
        minimum:      0
        maximum:      32
        unit:         "px"
    }

    SliderSetting {
        visible:      vizModeSetting.value === "bars"
        settingKey:   "barWidth"
        label:        I18n.tr("Bar Width")
        description:  I18n.tr("Fixed bar width in pixels (0 = auto-fill evenly)")
        defaultValue: 0
        minimum:      0
        maximum:      32
        unit:         "px"
    }

    SliderSetting {
        visible:      vizModeSetting.value === "bars"
        settingKey:   "barRadius"
        label:        I18n.tr("Bar Corner Radius")
        defaultValue: 4
        minimum:      0
        maximum:      16
        unit:         "px"
    }

    // ── Curve Layout ───────────────────────────────────────────────
    SliderSetting {
        visible:      vizModeSetting.value !== "bars"
        settingKey:   "curvePoints"
        label:        I18n.tr("Sample Points")
        description:  I18n.tr("Number of frequency bands sampled for the curve")
        defaultValue: 32
        minimum:      8
        maximum:      128
    }

    SliderSetting {
        visible:      vizModeSetting.value !== "bars"
        settingKey:   "curveLineWidth"
        label:        I18n.tr("Curve Line Width")
        defaultValue: 2
        minimum:      1
        maximum:      8
        unit:         "px"
    }

    // ── Orientation ────────────────────────────────────────────────
    SelectionSetting {
        settingKey:   "orientation"
        label:        I18n.tr("Orientation")
        defaultValue: "bottom"
        options: [
            { label: I18n.tr("Bottom"),     value: "bottom"     },
            { label: I18n.tr("Top"),        value: "top"        },
            { label: I18n.tr("Left"),       value: "left"       },
            { label: I18n.tr("Right"),      value: "right"      },
            { label: I18n.tr("Horizontal"), value: "horizontal" },
            { label: I18n.tr("Vertical"),   value: "vertical"   }
        ]
    }

    // ── Audio Settings ─────────────────────────────────────────────
    SliderSetting {
        settingKey:   "sensitivity"
        label:        I18n.tr("Sensitivity")
        defaultValue: 120
        minimum:      10
        maximum:      300
        unit:         "%"
    }

    SelectionSetting {
        settingKey:   "audioTarget"
        label:        I18n.tr("Audio Capture Source")
        description:  I18n.tr("Target all desktop output streams via PipeWire or PulseAudio")
        defaultValue: "all-outputs"
        options: [
            { label: I18n.tr("All Output Streams (PipeWire autoconnect)"), value: "all-outputs" },
            { label: I18n.tr("Default Audio Sink Monitor"),              value: "default-sink" },
            { label: I18n.tr("PipeWire Native Auto"),                    value: "pipewire"     }
        ]
    }

    SelectionSetting {
        settingKey:   "channels"
        label:        I18n.tr("Channels")
        description:  I18n.tr("Stereo mirrors both channels with low frequencies in center. Mono outputs left to right.")
        defaultValue: "mono"
        options: [
            { label: I18n.tr("Mono"),   value: "mono"   },
            { label: I18n.tr("Stereo"), value: "stereo" }
        ]
    }

    // ── Appearance ─────────────────────────────────────────────────
    SliderSetting {
        settingKey:   "silenceTimeout"
        label:        I18n.tr("Fade Out Delay")
        description:  I18n.tr("Seconds of silence before the visualizer fades out")
        defaultValue: 5
        minimum:      1
        maximum:      30
        unit:         "s"
    }

    SliderSetting {
        settingKey:   "bgOpacity"
        label:        I18n.tr("Background Card Opacity")
        defaultValue: 0
        minimum:      0
        maximum:      100
        unit:         "%"
    }

    SliderSetting {
        settingKey:   "opacity"
        label:        I18n.tr("Visualizer Opacity")
        defaultValue: 85
        minimum:      0
        maximum:      100
        unit:         "%"
    }
}
