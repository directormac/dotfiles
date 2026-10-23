import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    // ── Settings ───────────────────────────────────────────────────
    readonly property string vizMode:        pluginData.vizMode        ?? "bars"
    readonly property int    barCount:       pluginData.barCount       ?? 73
    readonly property int    curvePoints:    pluginData.curvePoints    ?? 32
    readonly property int    barSpacing:     pluginData.barSpacing     ?? 0
    readonly property int    barWidth:       pluginData.barWidth       ?? 0
    readonly property int    barRadius:      pluginData.barRadius      ?? 4
    readonly property int    curveLineWidth: pluginData.curveLineWidth ?? 2
    readonly property int    sensitivity:    pluginData.sensitivity    ?? 120
    readonly property string audioTarget:    pluginData.audioTarget    ?? "all-outputs"
    readonly property string channels:       pluginData.channels       ?? "mono"
    readonly property string orientation:    pluginData.orientation    ?? "bottom"
    readonly property string colorChoice:    pluginData.colorChoice    ?? "catppuccin"
    readonly property real   bgOpacity:      (pluginData.bgOpacity     ?? 0) / 100
    readonly property real   fgOpacity:      (pluginData.opacity       ?? 85) / 100

    readonly property int effectiveBars: vizMode === "bars" ? barCount : curvePoints

    implicitWidth:  500
    implicitHeight: 140

    // ── Color Palettes ─────────────────────────────────────────────
    readonly property var catppuccinPalette: [
        "#f5c2e7", // Pink
        "#cba6f7", // Mauve
        "#b4befe", // Lavender
        "#89b4fa", // Blue
        "#74c7ec", // Sapphire
        "#89dceb", // Sky
        "#94e2d5", // Teal
        "#a6e3a1", // Green
        "#f9e2af", // Yellow
        "#fab387", // Peach
        "#eba0ac", // Maroon
        "#f38ba8", // Red
        "#f2cdcd", // Flamingo
        "#f5e0dc"  // Rosewater
    ]

    readonly property var themePalette: [
        Theme.primary,
        Theme.secondary,
        Theme.tertiary,
        Theme.info,
        Theme.success,
        Theme.warning,
        Theme.error
    ]

    function getPaletteColor(index, total) {
        const t = Math.max(0, Math.min(1, index / Math.max(1, total - 1)));
        if (colorChoice === "catppuccin") {
            const idx = Math.floor(t * (catppuccinPalette.length - 1));
            return catppuccinPalette[idx % catppuccinPalette.length];
        }
        if (colorChoice === "theme-palette") {
            const idx = Math.floor(t * (themePalette.length - 1));
            return themePalette[idx % themePalette.length];
        }
        if (colorChoice === "secondary") return Theme.secondary;
        if (colorChoice === "surface")   return Theme.surfaceVariantText;
        return Theme.primary;
    }

    readonly property bool isMultiColor: colorChoice === "catppuccin" || colorChoice === "theme-palette"
    readonly property bool useGradient:  colorChoice === "gradient"

    // ── Internal State ─────────────────────────────────────────────
    property var  barValues:     []
    property bool isSilent:      true
    property bool fadedOut:      true
    property bool hasPlayedOnce: false

    readonly property int silenceTimeout: (pluginData.silenceTimeout ?? 5) * 1000

    onIsSilentChanged: {
        if (isSilent) {
            if (hasPlayedOnce) silenceTimer.restart()
        } else {
            hasPlayedOnce = true
            silenceTimer.stop()
            fadedOut = false
        }
    }

    Timer {
        id: silenceTimer
        repeat: false
        interval: root.silenceTimeout
        onTriggered: root.fadedOut = true
    }

    opacity: fadedOut ? 0.0 : 1.0
    Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }

    // ── Cava Process & Audio Capture Config ────────────────────────
    readonly property string confPath: {
        const tmp = Paths.strip(StandardPaths.writableLocation(StandardPaths.TempLocation)) || "/tmp"
        return `${tmp}/cava-widget-${root.instanceId || "default"}.cfg`
    }

    Timer {
        id: rebuildTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (cavaProcess.running) {
                cavaProcess.running = false
                restartTimer.restart()
            } else {
                cavaProcess.running = true
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 100
        repeat: false
        onTriggered: cavaProcess.running = true
    }

    function rebuildConfig() {
        rebuildTimer.restart()
    }

    // Build the input section based on user configuration to target all audio outputs
    readonly property string inputSection: {
        if (root.audioTarget === "default-sink") {
            return "[input]\nmethod = pulse\nsource = auto\n"
        }
        // all-outputs or pipewire: monitors audio output streams with autoconnect
        return "[input]\nmethod = pipewire\nsource = auto\nautoconnect = 2\nremix = 1\nactive = 1\n"
    }

    Process {
        id: cavaProcess
        command: [
            "sh", "-c",
            `cat << 'CAVACONF' > "${root.confPath}"
[general]
bars = ${root.effectiveBars}
framerate = 60
sensitivity = ${root.sensitivity}
channels = ${root.channels}
sleep_timer = 2

${root.inputSection}

[output]
method = raw
channels = ${root.channels}
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 1000
bar_delimiter = 59
frame_delimiter = 10
CAVACONF
exec cava -p "${root.confPath}" < /dev/null`
        ]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                if (!line || line.length === 0) return
                const parts = line.split(";")
                const vals = []
                let silent = true
                for (let i = 0; i < parts.length; i++) {
                    const n = parseInt(parts[i], 10)
                    if (!isNaN(n)) {
                        const v = Math.min(1.0, n / 1000.0)
                        vals.push(v)
                        if (v > 0.01) silent = false
                    }
                }
                if (vals.length > 0) {
                    root.barValues = vals
                    root.isSilent = silent
                }
            }
        }
    }

    Component.onCompleted:      rebuildConfig()
    Component.onDestruction:    cavaProcess.running = false
    onEffectiveBarsChanged:     rebuildConfig()
    onSensitivityChanged:       rebuildConfig()
    onChannelsChanged:          rebuildConfig()
    onAudioTargetChanged:       rebuildConfig()
    onVizModeChanged:           rebuildConfig()

    // ── Background Card ────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:   Theme.surface
        opacity: root.bgOpacity
        radius:  Theme.cornerRadius
    }

    // ── Visualization Container ────────────────────────────────────
    Item {
        id: vis
        anchors.fill:    parent
        anchors.margins: 0
        clip:            true

        readonly property real effectiveBarW: root.barWidth > 0
            ? root.barWidth
            : Math.max(1, (width - (root.effectiveBars - 1) * root.barSpacing) / root.effectiveBars)

        readonly property real effectiveBarH: root.barWidth > 0
            ? root.barWidth
            : Math.max(1, (height - (root.effectiveBars - 1) * root.barSpacing) / root.effectiveBars)

        // ── BARS: BOTTOM / TOP / HORIZONTAL ──
        Row {
            visible: root.vizMode === "bars"
                  && (root.orientation === "bottom"
                   || root.orientation === "top"
                   || root.orientation === "horizontal")
            width:   parent.width
            height:  parent.height
            spacing: root.barSpacing

            Repeater {
                model: root.vizMode === "bars" ? root.barCount : 0
                delegate: Rectangle {
                    required property int index
                    readonly property real norm: root.barValues[index] ?? 0.0
                    readonly property color bColor: root.getPaletteColor(index, root.barCount)

                    width:  vis.effectiveBarW
                    height: Math.max(2, norm * vis.height)
                    y:      root.orientation === "bottom"     ? vis.height - height
                          : root.orientation === "horizontal" ? vis.height / 2 - height / 2
                          :                                     0

                    Behavior on height { SmoothedAnimation { velocity: vis.height * 4.5 } }

                    radius: root.barRadius
                    color: Qt.rgba(bColor.r, bColor.g, bColor.b, root.fgOpacity * (0.80 + norm * 0.20))
                    gradient: root.useGradient ? rowGrad : null

                    Gradient {
                        id: rowGrad
                        orientation: Gradient.Vertical
                        GradientStop {
                            position: 0.0
                            color: root.orientation === "top"
                                ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, root.fgOpacity)
                                : Qt.rgba(Theme.primary.r,   Theme.primary.g,   Theme.primary.b,   root.fgOpacity)
                        }
                        GradientStop {
                            position: 1.0
                            color: root.orientation === "top"
                                ? Qt.rgba(Theme.primary.r,   Theme.primary.g,   Theme.primary.b,   root.fgOpacity)
                                : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, root.fgOpacity)
                        }
                    }
                }
            }
        }

        // ── BARS: LEFT / RIGHT / VERTICAL ──
        Column {
            visible: root.vizMode === "bars"
                  && (root.orientation === "left"
                   || root.orientation === "right"
                   || root.orientation === "vertical")
            width:   parent.width
            height:  parent.height
            spacing: root.barSpacing

            Repeater {
                model: root.vizMode === "bars" ? root.barCount : 0
                delegate: Rectangle {
                    required property int index
                    readonly property real norm: root.barValues[index] ?? 0.0
                    readonly property color bColor: root.getPaletteColor(index, root.barCount)

                    height: vis.effectiveBarH
                    width:  Math.max(2, norm * vis.width)
                    x:      root.orientation === "right"    ? vis.width - width
                          : root.orientation === "vertical" ? vis.width / 2 - width / 2
                          :                                   0

                    Behavior on width { SmoothedAnimation { velocity: vis.width * 4.5 } }

                    radius: root.barRadius
                    color: Qt.rgba(bColor.r, bColor.g, bColor.b, root.fgOpacity * (0.80 + norm * 0.20))
                    gradient: root.useGradient ? colGrad : null

                    Gradient {
                        id: colGrad
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: root.orientation === "left"
                                ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, root.fgOpacity)
                                : Qt.rgba(Theme.primary.r,   Theme.primary.g,   Theme.primary.b,   root.fgOpacity)
                        }
                        GradientStop {
                            position: 1.0
                            color: root.orientation === "left"
                                ? Qt.rgba(Theme.primary.r,   Theme.primary.g,   Theme.primary.b,   root.fgOpacity)
                                : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, root.fgOpacity)
                        }
                    }
                }
            }
        }

        // ── CURVE: OUTLINE / FILLED ──
        Canvas {
            id: curveCanvas

            visible: root.vizMode === "curve-outline" || root.vizMode === "curve-filled"
            anchors.fill: parent

            Connections {
                target: root
                function onBarValuesChanged()   { if (curveCanvas.visible) curveCanvas.requestPaint() }
                function onVizModeChanged()     { if (curveCanvas.visible) curveCanvas.requestPaint() }
                function onOrientationChanged() { if (curveCanvas.visible) curveCanvas.requestPaint() }
                function onColorChoiceChanged() { if (curveCanvas.visible) curveCanvas.requestPaint() }
                function onFgOpacityChanged()   { if (curveCanvas.visible) curveCanvas.requestPaint() }
            }

            onPaint: {
                const ctx  = getContext("2d")
                const w    = width
                const h    = height
                const vals = root.barValues
                const n    = vals.length

                ctx.clearRect(0, 0, w, h)
                if (n < 2) return

                const orient = root.orientation
                const points = []

                for (let i = 0; i < n; i++) {
                    const t   = i / (n - 1)
                    const amp = vals[i]

                    let px, py
                    if (orient === "top") {
                        px = t * w
                        py = amp * h
                    } else if (orient === "horizontal") {
                        px = t * w
                        py = h / 2 - amp * (h / 2)
                    } else if (orient === "vertical") {
                        px = w / 2 - amp * (w / 2)
                        py = t * h
                    } else if (orient === "left") {
                        px = amp * w
                        py = t * h
                    } else if (orient === "right") {
                        px = w - amp * w
                        py = t * h
                    } else {
                        px = t * w
                        py = h - amp * h
                    }
                    points.push({ x: px, y: py })
                }

                function drawSpline(pts) {
                    const len = pts.length
                    ctx.beginPath()
                    ctx.moveTo(pts[0].x, pts[0].y)
                    for (let i = 0; i < len - 1; i++) {
                        const p0 = pts[Math.max(0, i - 1)]
                        const p1 = pts[i]
                        const p2 = pts[i + 1]
                        const p3 = pts[Math.min(len - 1, i + 2)]

                        const cp1x = p1.x + (p2.x - p0.x) / 6
                        const cp1y = p1.y + (p2.y - p0.y) / 6
                        const cp2x = p2.x - (p3.x - p1.x) / 6
                        const cp2y = p2.y - (p3.y - p1.y) / 6

                        ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y)
                    }
                }

                function makePaint() {
                    if (root.colorChoice === "catppuccin") {
                        const grad = ctx.createLinearGradient(0, 0, w, 0)
                        const p = root.catppuccinPalette
                        for (let k = 0; k < p.length; k++) {
                            grad.addColorStop(k / (p.length - 1), p[k])
                        }
                        return grad
                    }
                    if (root.colorChoice === "theme-palette") {
                        const grad = ctx.createLinearGradient(0, 0, w, 0)
                        const p = root.themePalette
                        for (let k = 0; k < p.length; k++) {
                            grad.addColorStop(k / (p.length - 1), p[k])
                        }
                        return grad
                    }
                    if (root.useGradient) {
                        const grad = ctx.createLinearGradient(0, 0, w, 0)
                        grad.addColorStop(0, Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, root.fgOpacity))
                        grad.addColorStop(1, Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, root.fgOpacity))
                        return grad
                    }
                    const col = root.getPaletteColor(0, 1)
                    return Qt.rgba(col.r, col.g, col.b, root.fgOpacity)
                }

                const paintColor = makePaint()
                const isFilled   = root.vizMode === "curve-filled"

                if (orient === "horizontal") {
                    drawSpline(points)
                    const mirrorH = points.map(p => ({ x: p.x, y: h - p.y }))
                    for (let i = mirrorH.length - 2; i >= 0; i--) {
                        const p0 = mirrorH[Math.min(mirrorH.length - 1, i + 2)]
                        const p1 = mirrorH[i + 1]
                        const p2 = mirrorH[i]
                        const p3 = mirrorH[Math.max(0, i - 1)]

                        const cp1x = p1.x + (p2.x - p0.x) / 6
                        const cp1y = p1.y + (p2.y - p0.y) / 6
                        const cp2x = p2.x - (p3.x - p1.x) / 6
                        const cp2y = p2.y - (p3.y - p1.y) / 6

                        ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y)
                    }
                    ctx.closePath()

                    if (isFilled) {
                        ctx.fillStyle = paintColor
                        ctx.fill()
                    }
                    if (root.curveLineWidth > 0) {
                        drawSpline(points)
                        ctx.strokeStyle = paintColor
                        ctx.lineWidth   = root.curveLineWidth
                        ctx.lineJoin    = "round"
                        ctx.lineCap     = "round"
                        ctx.stroke()
                        drawSpline(mirrorH)
                        ctx.stroke()
                    }

                } else if (orient === "vertical") {
                    drawSpline(points)
                    const mirrorV = points.map(p => ({ x: w - p.x, y: p.y }))
                    for (let i = mirrorV.length - 2; i >= 0; i--) {
                        const p0 = mirrorV[Math.min(mirrorV.length - 1, i + 2)]
                        const p1 = mirrorV[i + 1]
                        const p2 = mirrorV[i]
                        const p3 = mirrorV[Math.max(0, i - 1)]

                        const cp1x = p1.x + (p2.x - p0.x) / 6
                        const cp1y = p1.y + (p2.y - p0.y) / 6
                        const cp2x = p2.x - (p3.x - p1.x) / 6
                        const cp2y = p2.y - (p3.y - p1.y) / 6

                        ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y)
                    }
                    ctx.closePath()

                    if (isFilled) {
                        ctx.fillStyle = paintColor
                        ctx.fill()
                    }
                    if (root.curveLineWidth > 0) {
                        drawSpline(points)
                        ctx.strokeStyle = paintColor
                        ctx.lineWidth   = root.curveLineWidth
                        ctx.lineJoin    = "round"
                        ctx.lineCap     = "round"
                        ctx.stroke()
                        drawSpline(mirrorV)
                        ctx.stroke()
                    }

                } else if (isFilled) {
                    drawSpline(points)
                    if (orient === "left") {
                        ctx.lineTo(0, points[n - 1].y)
                        ctx.lineTo(0, points[0].y)
                    } else if (orient === "right") {
                        ctx.lineTo(w, points[n - 1].y)
                        ctx.lineTo(w, points[0].y)
                    } else {
                        const baselineY = orient === "top" ? 0 : h
                        ctx.lineTo(points[n - 1].x, baselineY)
                        ctx.lineTo(points[0].x,     baselineY)
                    }
                    ctx.closePath()
                    ctx.fillStyle = paintColor
                    ctx.fill()

                    if (root.curveLineWidth > 0) {
                        drawSpline(points)
                        ctx.strokeStyle = paintColor
                        ctx.lineWidth   = root.curveLineWidth
                        ctx.lineJoin    = "round"
                        ctx.lineCap     = "round"
                        ctx.stroke()
                    }

                } else {
                    drawSpline(points)
                    ctx.strokeStyle = paintColor
                    ctx.lineWidth   = root.curveLineWidth
                    ctx.lineJoin    = "round"
                    ctx.lineCap     = "round"
                    ctx.stroke()
                }
            }
        }
    }
}
