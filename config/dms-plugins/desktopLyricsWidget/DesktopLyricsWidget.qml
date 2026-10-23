import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Common
import qs.Services
import qs.Widgets
import qs.DCommon.Widgets
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    // ── Display & Typography Settings ──────────────────────────────
    readonly property real   fontSize:                 pluginData.fontSize                 ?? 38
    readonly property int    lineCount:                parseInt(pluginData.lineCount       ?? "7")
    readonly property string textAlign:                pluginData.textAlign                ?? "center"
    readonly property string colorMode:                pluginData.colorMode                ?? "catppuccin"
    readonly property var    customColor:              pluginData.customColor              ?? Theme.primary
    readonly property string activeLinePillStyle:      pluginData.activeLinePillStyle      ?? "pill"
    readonly property real   activeLinePillOpacity:    (pluginData.activeLinePillOpacity   ?? 75) / 100
    readonly property real   activeLineBorderOpacity:  (pluginData.activeLineBorderOpacity ?? 50) / 100
    readonly property bool   textShadow:               pluginData.textShadow               ?? true
    readonly property real   backgroundOpacity:        (pluginData.backgroundOpacity       ?? 0) / 100
    readonly property real   borderOpacity:            (pluginData.borderOpacity           ?? 0) / 100
    readonly property real   cardRadius:               pluginData.cardRadius               ?? 20

    // Catppuccin color palette for word-by-word karaoke highlighting
    readonly property var catppuccinWordColors: [
        "#cba6f7", // Mauve
        "#f5c2e7", // Pink
        "#89b4fa", // Blue
        "#a6e3a1", // Green
        "#fab387", // Peach
        "#94e2d5"  // Teal
    ]

    readonly property color accentColor: {
        if (root.colorMode === "mauve" || root.colorMode === "catppuccin") return "#cba6f7";
        if (root.colorMode === "pink")      return "#f5c2e7";
        if (root.colorMode === "secondary") return Theme.secondary;
        if (root.colorMode === "custom" && root.customColor) {
            if (typeof root.customColor === "string") return root.customColor;
            if (root.customColor.valid) return root.customColor;
        }
        return Theme.primary;
    }

    implicitWidth:  700
    implicitHeight: Math.max(120, root.fontSize * root.lineCount * 1.6 + Theme.spacingL * 2)

    // ── Lyrics Service & Controller ────────────────────────────────
    readonly property var controller: LyricsService.controller
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property bool isPlaying: activePlayer !== null && activePlayer.playbackState === MprisPlaybackState.Playing

    // Active song metadata (uses stable controller metadata with player fallback)
    readonly property string currentTrackTitle: {
        if (activePlayer?.trackTitle) return activePlayer.trackTitle;
        if (MprisController.stableTitle) return MprisController.stableTitle;
        return "";
    }

    readonly property string currentTrackArtist: {
        if (activePlayer?.trackArtist) return activePlayer.trackArtist;
        if (MprisController.stableArtist) return MprisController.stableArtist;
        return "";
    }

    LyricsSubscription {
        active: root.visible
    }

    readonly property bool hasSyncedLyrics: controller.state === "ready" && controller.synced && (controller.lines?.length ?? 0) > 0
    readonly property bool hasPlainLyrics:  controller.state === "ready" && !controller.synced && (controller.plainLines?.length ?? 0) > 0
    readonly property bool hasLyrics:       hasSyncedLyrics || hasPlainLyrics

    readonly property int activeIdx: hasSyncedLyrics ? Math.max(0, controller.activeIndex) : 0

    // High-precision playback clock for word synchronization
    property real nowTime: 0

    Timer {
        id: syncTimer
        interval: 35
        repeat: true
        running: root.visible && root.isPlaying && root.hasSyncedLyrics
        onTriggered: {
            root.nowTime = root.controller.currentTime ? root.controller.currentTime() : (root.controller.sampleTime ?? 0);
        }
    }

    onActiveIdxChanged: {
        root.nowTime = root.controller.currentTime ? root.controller.currentTime() : (root.controller.sampleTime ?? 0);
    }

    function escapeHtml(text) {
        if (!text) return "";
        return String(text)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    function buildWordsHtml(words, activeWordIdx) {
        if (!words || words.length === 0) return "";
        const palette = root.catppuccinWordColors;
        return words.map((word, wIdx) => {
            const text = escapeHtml(word.x);
            if (wIdx < activeWordIdx) {
                // Word already sung in the active line
                const c = root.colorMode === "catppuccin" ? palette[wIdx % palette.length] : root.accentColor;
                return `<font color="${c}">${text}</font>`;
            } else if (wIdx === activeWordIdx) {
                // Word currently being sung (bold + bright pink / palette accent)
                const c = root.colorMode === "catppuccin" ? palette[wIdx % palette.length] : "#f5c2e7";
                return `<font color="${c}"><b>${text}</b></font>`;
            }
            // Upcoming word in active line - soft muted tone
            return `<font color="#a6adc8">${text}</font>`;
        }).join("");
    }

    // ── Outer Background Card (Optional) ───────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: root.cardRadius
        color: root.backgroundOpacity > 0 ? Theme.withAlpha(Theme.surfaceContainerHighest, root.backgroundOpacity) : "transparent"
        border.color: root.borderOpacity > 0 ? Theme.withAlpha(Theme.outline, root.borderOpacity) : "transparent"
        border.width: root.borderOpacity > 0 ? 1 : 0
        visible: root.backgroundOpacity > 0 || root.borderOpacity > 0
    }

    // ── Song Title & Artist Fallback (When Lyrics are Unavailable) ──
    // Generously wide, elegant card (650px up to 1200px) so long titles never cramp
    Item {
        id: fallbackCard
        anchors.centerIn: parent
        readonly property real cardWidth: Math.min(root.width - Theme.spacingXL * 2, Math.max(650, Math.min(root.width * 0.85, 1200)))
        width: cardWidth
        height: fallbackCol.implicitHeight + Theme.spacingXL * 2
        visible: !root.hasLyrics

        Rectangle {
            anchors.fill: parent
            radius: root.cardRadius
            color: Theme.withAlpha(Theme.surfaceContainerLowest || "#181825", root.activeLinePillOpacity)
            border.color: Theme.withAlpha(root.accentColor, root.activeLineBorderOpacity)
            border.width: root.activeLineBorderOpacity > 0 ? 1.5 : 0
            visible: root.activeLinePillStyle !== "none"
        }

        Column {
            id: fallbackCol
            anchors.centerIn: parent
            width: parent.width - Theme.spacingXL * 2
            spacing: Theme.spacingS

            // Subtle Status Chip (Searching lyrics / Instrumental)
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingXS
                visible: root.controller.state === "loading" || root.controller.state === "instrumental"

                DIcon {
                    name: root.controller.state === "instrumental" ? "music_note" : "sync"
                    size: 14
                    color: root.accentColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: root.controller.state === "instrumental" ? I18n.tr("Instrumental") : I18n.tr("Searching lyrics…")
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: root.accentColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Prominent Track Title
            StyledText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: root.fontSize * 0.95
                font.weight: Font.DemiBold
                color: root.accentColor
                style: root.textShadow ? Text.Outline : Text.Normal
                styleColor: Qt.rgba(0, 0, 0, 0.8)
                text: root.currentTrackTitle || I18n.tr("Nothing Playing")
            }

            // Artist & Album Subtitle
            StyledText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: root.fontSize * 0.62
                font.weight: Font.Normal
                color: Theme.surfaceText
                style: root.textShadow ? Text.Outline : Text.Normal
                styleColor: Qt.rgba(0, 0, 0, 0.6)
                visible: root.currentTrackArtist !== ""
                text: root.currentTrackArtist
            }
        }
    }

    // ── Main Lyrics ListView ───────────────────────────────────────
    ListView {
        id: lyricsList
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        visible: root.hasLyrics
        clip: true
        model: root.hasSyncedLyrics ? root.controller.lines : root.controller.plainLines
        currentIndex: root.activeIdx
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: height * 0.5 - (root.fontSize * 1.6) / 2
        preferredHighlightEnd:   height * 0.5 + (root.fontSize * 1.6) / 2
        spacing: root.fontSize * 0.22

        header: Item {
            width: 1
            height: Math.max(0, (lyricsList.height - root.fontSize * 1.6) / 2)
        }
        footer: Item {
            width: 1
            height: Math.max(0, (lyricsList.height - root.fontSize * 1.6) / 2)
        }

        Behavior on contentY {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        delegate: Item {
            id: lineDelegate
            required property int index
            required property var modelData

            readonly property int    dist:     Math.abs(index - lyricsList.currentIndex)
            readonly property int    maxDist:  Math.floor(root.lineCount / 2)
            readonly property bool   isCurrent: dist === 0

            width: lyricsList.width
            height: Math.max(root.fontSize * 1.5, lyricCol.implicitHeight + (isCurrent ? Theme.spacingM * 2 : Theme.spacingXS))

            // Dynamic High-Contrast Active Line Backdrop Pill
            Rectangle {
                id: activePill
                visible: lineDelegate.isCurrent && root.activeLinePillStyle !== "none"
                anchors.centerIn: parent
                width: {
                    if (root.activeLinePillStyle === "full") return parent.width;
                    return Math.min(parent.width, lyricCol.implicitWidth + Theme.spacingXL * 2);
                }
                height: lyricCol.implicitHeight + Theme.spacingM * 2
                radius: root.cardRadius
                color: Theme.withAlpha(Theme.surfaceContainerLowest || "#181825", root.activeLinePillOpacity)
                border.color: Theme.withAlpha(root.accentColor, root.activeLineBorderOpacity)
                border.width: root.activeLineBorderOpacity > 0 ? 1.5 : 0

                Behavior on width  { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            }

            // Click-to-seek
            MouseArea {
                anchors.fill: parent
                cursorShape: root.hasSyncedLyrics && root.activePlayer?.canSeek ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (root.hasSyncedLyrics && root.activePlayer?.canSeek) {
                        if (typeof root.controller.seekToLine === "function") {
                            root.controller.seekToLine(lineDelegate.index)
                        } else if (modelData?.t !== undefined) {
                            root.activePlayer.position = modelData.t
                        }
                    }
                }
            }

            // Vocal parts container (supports multi-line wrapped lyrics and duets/background parts)
            Column {
                id: lyricCol
                anchors.centerIn: parent
                width: Math.min(parent.width - Theme.spacingM * 2, implicitWidth > 0 ? implicitWidth : parent.width)
                spacing: Theme.spacingXS

                Repeater {
                    model: {
                        if (!lineDelegate.modelData) return [];
                        if (root.hasSyncedLyrics && lineDelegate.modelData.parts && lineDelegate.modelData.parts.length > 0) {
                            return lineDelegate.modelData.parts;
                        }
                        return [lineDelegate.modelData];
                    }

                    delegate: Text {
                        id: partText
                        required property int index
                        required property var modelData

                        width: lineDelegate.width - Theme.spacingL * 2
                        wrapMode: Text.WordWrap
                        horizontalAlignment: {
                            if (root.textAlign === "left")  return Text.AlignLeft;
                            if (root.textAlign === "right") return Text.AlignRight;
                            return Text.AlignHCenter;
                        }

                        // Always StyledText so any HTML formatting renders cleanly, never prints raw tags
                        textFormat: Text.StyledText

                        // ── High-Performance Word Timing State Machine ──
                        property int cachedWordIdx: -2
                        property string cachedHtml: ""

                        function getActiveWordIdx(words, atTime) {
                            if (!words || words.length === 0) return -1;
                            let last = -1;
                            for (let i = 0; i < words.length; i++) {
                                if (atTime >= words[i].t) last = i;
                                else break;
                            }
                            return last;
                        }

                        function updateWordHtml() {
                            // Inactive / past line: MUST strip all font tags and show clean plain text!
                            if (!lineDelegate.isCurrent) {
                                cachedWordIdx = -1;
                                const raw = modelData?.x ?? (typeof modelData === "string" ? modelData : "");
                                cachedHtml = root.escapeHtml(raw.trim() === "" ? "♪" : raw);
                                return;
                            }

                            // Active line without individual word timing: colorize active line in accent
                            if (!root.hasSyncedLyrics || !modelData?.w || modelData.w.length === 0) {
                                cachedWordIdx = -1;
                                const raw = modelData?.x ?? (typeof modelData === "string" ? modelData : "");
                                cachedHtml = `<font color="${root.accentColor}">${root.escapeHtml(raw)}</font>`;
                                return;
                            }

                            // Active line with word timing: only update when the current word index changes!
                            const currentIdx = getActiveWordIdx(modelData.w, root.nowTime);
                            if (currentIdx === cachedWordIdx) {
                                return;
                            }
                            cachedWordIdx = currentIdx;
                            cachedHtml = root.buildWordsHtml(modelData.w, currentIdx);
                        }

                        // React to playback time advancing
                        Connections {
                            target: root
                            function onNowTimeChanged() {
                                if (lineDelegate.isCurrent) {
                                    partText.updateWordHtml();
                                }
                            }
                        }

                        // Immediately strip HTML tags and color as soon as this line is no longer current!
                        Connections {
                            target: lineDelegate
                            function onIsCurrentChanged() {
                                partText.cachedWordIdx = -2;
                                partText.updateWordHtml();
                            }
                        }

                        Component.onCompleted: updateWordHtml()
                        onModelDataChanged: {
                            cachedWordIdx = -2;
                            updateWordHtml();
                        }

                        text: cachedHtml

                        // Drop shadow outline for crisp contrast on bright wallpapers
                        style: root.textShadow ? Text.Outline : Text.Normal
                        styleColor: lineDelegate.isCurrent ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.55)

                        font.pixelSize: {
                            if (lineDelegate.isCurrent) return root.fontSize
                            if (lineDelegate.dist === 1) return root.fontSize * 0.86
                            if (lineDelegate.dist === 2) return root.fontSize * 0.73
                            return root.fontSize * 0.62
                        }
                        font.weight: lineDelegate.isCurrent ? Font.DemiBold : Font.Normal
                        color: lineDelegate.isCurrent ? root.accentColor : Theme.surfaceText

                        opacity: {
                            if (lineDelegate.dist > lineDelegate.maxDist) return 0.0
                            if (text === "♪")                              return 0.25
                            if (lineDelegate.isCurrent)                   return 1.0
                            if (lineDelegate.dist === 1)                  return 0.68
                            if (lineDelegate.dist === 2)                  return 0.40
                            return 0.20
                        }

                        Behavior on font.pixelSize { NumberAnimation { duration: 150 } }
                        Behavior on opacity        { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        Behavior on color          { ColorAnimation  { duration: 150 } }
                    }
                }
            }
        }
    }
}
