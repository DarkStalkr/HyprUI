import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "../services"

Scope {
    id: root
    required property ShellScreen screen

    readonly property MprisPlayer player: Players.active
    readonly property bool hasPlayer: !!player
    
    // Auto-show when metadata or status changes, then hide
    property bool active: false
    
    function triggerShow() {
        if (active) {
            hideTimer.restart();
        } else {
            showDelayTimer.restart();
        }
    }

    Component.onDestruction: {
        showDelayTimer.stop();
        hideTimer.stop();
    }

    Timer {
        id: showDelayTimer
        interval: 3000 // Debounce show to avoid flickering during metadata changes (e.g. YouTube hovering)
        onTriggered: {
            root.active = true;
            hideTimer.restart();
        }
    }

    Connections {
        target: player
        enabled: player !== null
        function onMetadataChanged() { triggerShow(); }
        function onIsPlayingChanged() { triggerShow(); }
        function onPostTrackChanged() { triggerShow(); }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.active = false
    }

    PanelWindow {
        id: win
        screen: root.screen
        // Only show if we have a player AND it's active (timed show)
        visible: hasPlayer && active
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-media"
        WlrLayershell.exclusiveZone: -1
        
        anchors {
            top: true
            right: true
        }
        
        implicitWidth: 400
        implicitHeight: 180
        color: "transparent"

        Rectangle {
            id: container
            anchors.fill: parent
            anchors.margins: 20
            
            radius: HyprUITheme.active.rounding ?? 12
            color: HyprUITheme.active.background ?? "#1e1e2e"
            opacity: active ? 0.95 : 0.0
            scale: active ? 1.0 : 0.9
            border.color: HyprUITheme.primary ?? "#cba6f7"
            border.width: 1

            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

            MouseArea {
                anchors.fill: parent
                onClicked: active = false
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Album Art
                Rectangle {
                    width: 100
                    height: 100
                    radius: (HyprUITheme.active.rounding ?? 12) / 2
                    clip: true
                    color: HyprUITheme.active.surface ?? "#313244"

                    Image {
                        id: coverImage
                        anchors.fill: parent
                        source: player?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        
                        Text {
                            visible: parent.status !== Image.Ready
                            anchors.centerIn: parent
                            text: "󰝚"
                            font.pixelSize: 40
                            color: HyprUITheme.active.text ?? "white"
                            opacity: 0.3
                        }
                    }
                }

                // Metadata & Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        Layout.fillWidth: true
                        text: (player?.trackTitle || "Not Playing")
                        font.pixelSize: 18
                        font.bold: true
                        color: HyprUITheme.active.text ?? "white"
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: {
                            if (player?.trackArtists) {
                                // Check if trackArtists is an array before joining
                                if (Array.isArray(player.trackArtists)) {
                                    return player.trackArtists.join(", ");
                                } else {
                                    // If it's not an array, assume it's a string and return it directly
                                    return player.trackArtists;
                                }
                            }
                            return player?.trackArtist || "Unknown Artist";
                        }
                        font.pixelSize: 14
                        color: HyprUITheme.active.text ?? "white"
                        opacity: 0.7
                        elide: Text.ElideRight
                    }

                    Item { Layout.fillHeight: true }

                    // Progress Bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 4
                        radius: 2
                        color: HyprUITheme.active.surface ?? "#313244"

                        Rectangle {
                            width: parent.width * (player?.position / player?.length || 0)
                            height: parent.height
                            radius: 2
                            color: HyprUITheme.primary ?? "#cba6f7"
                        }
                    }

                    // Media Controls
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        Text {
                            text: "󰒮"
                            font.pixelSize: 20
                            color: !!(player?.canGoPrevious) ? (HyprUITheme.active.text ?? "white") : "gray"
                            opacity: !!(player?.canGoPrevious) ? 1.0 : 0.5
                            MouseArea { 
                                anchors.fill: parent
                                enabled: !!(player?.canGoPrevious)
                                onClicked: player?.previous() 
                            }
                        }

                        Text {
                            text: (player?.playbackState === MprisPlaybackState.Playing) ? "󰏤" : "󰐊"
                            font.pixelSize: 30
                            color: HyprUITheme.primary ?? "#cba6f7"
                            MouseArea { anchors.fill: parent; onClicked: player?.togglePlaying() }
                        }

                        Text {
                            text: "󰒭"
                            font.pixelSize: 20
                            color: !!(player?.canGoNext) ? (HyprUITheme.active.text ?? "white") : "gray"
                            opacity: !!(player?.canGoNext) ? 1.0 : 0.5
                            MouseArea { 
                                anchors.fill: parent
                                enabled: !!(player?.canGoNext)
                                onClicked: player?.next() 
                            }
                        }
                    }
                }
            }
        }
    }
}
