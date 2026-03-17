import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services"
import "../components"

Scope {
    id: root
    required property ShellScreen screen

    readonly property bool isFullscreen: {
        const monitor = Hypr.monitors.values.find(m => m.name === root.screen.name)
        return monitor && monitor.activeWorkspace ? monitor.activeWorkspace.hasFullscreen : false
    }

    PanelWindow {
        id: win
        screen: root.screen
        visible: !root.isFullscreen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-sidebar"
        WlrLayershell.exclusiveZone: UI.exclusiveZone

        anchors {
            top:    true
            bottom: true
            left:   true
        }

        implicitWidth: 400
        color: "transparent"

        mask: Region {
            width:  UI.exclusiveZone
            height: win.height
        }

        Rectangle {
            id: barBackground
            anchors.left:    parent.left
            anchors.top:     parent.top
            anchors.bottom:  parent.bottom
            anchors.margins: UI.panelMargin

            width: UI.panelThickness
            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            radius:  HyprUITheme.active.rounding
            color:   HyprUITheme.active.background
            opacity: 0.95
            border.color: Qt.rgba(HyprUITheme.primary.r, HyprUITheme.primary.g, HyprUITheme.primary.b, 0.4)
            border.width: 1

            ColumnLayout {
                anchors.fill:      parent
                anchors.topMargin: UI.panelMargin * 4
                spacing:           Math.round(UI.panelThickness * 0.33)

                // ── Pinned Apps slot ─────────────────────────────────────────
                //
                // THE CORRECT QML CENTERING PATTERN
                // ----------------------------------
                // Layout.alignment / Layout.fillWidth: false both rely on the
                // layout engine reading implicitWidth from the child *before* it
                // is fully constructed. For a Column driven by a Repeater, that
                // value is 0 at construction time, so the layout allocates a 0 px
                // cell and positions it at x=0 regardless of alignment hints.
                //
                // The only layout-system-agnostic solution is:
                //   1. Give the slot Item Layout.fillWidth: true  →  it always
                //      occupies the full strip width, no ambiguity.
                //   2. Anchor the actual content to parent.horizontalCenter
                //      inside that Item  →  pure geometry, evaluated after
                //      implicitWidth is known, immune to construction order.
                Item {
                    Layout.fillWidth: true
                    // Height tracks the Column so the slot doesn't collapse.
                    implicitHeight: iconsColumn.implicitHeight

                    Column {
                        id: iconsColumn
                        // This anchor is evaluated post-construction.
                        // It is the single source of truth for horizontal position.
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Math.round(UI.panelThickness * 0.25)

                        Repeater {
                            model: UI.pinnedApps
                            AppIcon {
                                appId: modelData
                                onUnpin: UI.pinnedApps = UI.pinnedApps.filter(id => id !== appId)
                            }
                        }
                    }
                }

                // Spacer
                Item { Layout.fillHeight: true }

                // ── Dashboard button slot ────────────────────────────────────
                // Same wrapper pattern: full-width slot, geometry-anchored content.
                Item {
                    Layout.fillWidth:    true
                    Layout.bottomMargin: Math.round(UI.panelThickness * 0.33)
                    implicitHeight:      dashBtn.btnSize

                    Rectangle {
                        id: dashBtn

                        // 70 % of strip width → symmetric inset at all presets:
                        //   large  → 42 px  (9 px each side of 60 px strip)
                        //   medium → 32 px  (7 px each side of 46 px strip)
                        //   small  → 24 px  (5 px each side of 34 px strip)
                        readonly property int btnSize: Math.round(UI.panelThickness * 0.70)

                        anchors.horizontalCenter: parent.horizontalCenter
                        width:  btnSize
                        height: btnSize
                        radius: btnSize / 2

                        color: UI.dashboardVisible ? HyprUITheme.primary : HyprUITheme.active.surface

                        Text {
                            anchors.centerIn: parent
                            text:           "󰕮"
                            font.family:    "MesloLGS NF"
                            font.pixelSize: UI.fontSize.md
                            color: UI.dashboardVisible ? HyprUITheme.active.background : HyprUITheme.active.text
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: UI.toggleDashboard()
                            hoverEnabled: true
                            onEntered: dashTooltip.requestShow()
                            onExited:  dashTooltip.requestHide()
                        }

                        Tooltip {
                            id:          dashTooltip
                            text:        "Toggle Dashboard"
                            orientation: "right"
                            parent:      win.contentItem
                            target:      dashBtn
                        }
                    }
                }
            }
        }
    }

    // ── AppIcon ───────────────────────────────────────────────────────────────
    component AppIcon: Rectangle {
        id: iconRoot
        property string appId
        signal unpin()
        readonly property var app: DesktopEntries.applications.values
                                       .find(a => a.id.toLowerCase().includes(appId.toLowerCase()))

        // 75 % of strip width — fits with ~12.5 % breathing room each side:
        //   large  → 45 px   medium → 35 px   small → 26 px
        readonly property int sz: Math.round(UI.panelThickness * 0.75)

        width:  sz
        height: sz
        radius: Math.round(sz * 0.27)

        color:        HyprUITheme.active.surface
        border.color: HyprUITheme.primary
        border.width: ma.containsMouse ? 1 : 0

        Image {
            anchors.fill:    parent
            anchors.margins: Math.max(4, Math.round(iconRoot.sz * 0.18))
            source:          app ? Quickshell.iconPath(app.icon) : Quickshell.iconPath("image-missing")
            fillMode:        Image.PreserveAspectFit
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onEntered: { parent.scale = 1.1; appTooltip.requestShow()  }
            onExited:  { parent.scale = 1.0; appTooltip.requestHide()  }
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    if (app) Apps.launch(app)
                } else {
                    unpin()
                }
            }
        }

        Tooltip {
            id:          appTooltip
            text:        app ? app.name : appId
            orientation: "right"
            parent:      win.contentItem
            target:      iconRoot
        }

        Behavior on scale        { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        Behavior on border.width { NumberAnimation { duration: 150 } }
    }
}
