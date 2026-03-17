pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // ─── UI States (reset on restart) ────────────────────────────────────────
    property bool launcherVisible: false
    property bool dashboardVisible: false
    property bool controlCenterVisible: false

    // ─── Persistent state ────────────────────────────────────────────────────
    property alias pinnedApps: _adapter.pinnedApps
    property alias currentSize: _adapter.currentSize

    property var _storage: FileView {
        path: Quickshell.statePath("pinnedApps.json")
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: _adapter
            property list<string> pinnedApps: ["librewolf", "kitty", "thunar", "vscodium"]
            // Persisted size preset. Treated as the canonical source of truth for
            // panel dimensions. Changing this property automatically updates all
            // bound components via the computed properties below.
            property string currentSize: "large"
        }
    }

    Component.onCompleted: _storage.reload()

    // ─── Size presets ─────────────────────────────────────────────────────────
    // Each preset defines the three independent knobs that drive both panels:
    //   panelThickness – the visual rectangle's height (TopBar) / width (SideBar)
    //   panelMargin    – spacing between the screen edge and the rectangle
    //   iconSize       – base size for icons and workspace indicators
    //
    // exclusiveZone is derived:  panelMargin + panelThickness + panelMargin
    // This keeps the formula transparent and avoids magic numbers in components.
    readonly property var _presets: ({
        "large":  { panelThickness: 60, panelMargin: 12, iconSize: 32, wsSize: 35, fontSize: { sm: 16, md: 18, lg: 24 } },
        "medium": { panelThickness: 46, panelMargin: 10, iconSize: 26, wsSize: 28, fontSize: { sm: 13, md: 15, lg: 20 } },
        "small":  { panelThickness: 34, panelMargin:  8, iconSize: 20, wsSize: 22, fontSize: { sm: 11, md: 12, lg: 16 } }
    })

    // Convenience aliases — components should bind to these, never to the raw
    // preset object, so the indirection stays in one place.
    readonly property int  panelThickness: _presets[currentSize].panelThickness
    readonly property int  panelMargin:    _presets[currentSize].panelMargin
    readonly property int  exclusiveZone:  panelMargin + panelThickness + panelMargin
    readonly property int  iconSize:       _presets[currentSize].iconSize
    readonly property int  wsSize:         _presets[currentSize].wsSize
    readonly property var  fontSize:       _presets[currentSize].fontSize

    // ─── cycleSize ────────────────────────────────────────────────────────────
    // Advances through small → medium → large → small …
    // Called by the GlobalShortcut registered in shell.qml.
    function cycleSize(): void {
        const order = ["large", "medium", "small"]
        const next  = order[(order.indexOf(currentSize) + 1) % order.length]
        currentSize = next

        // Provide feedback via internal notification system
        const preset = _presets[currentSize]
        const summary = "Size Preset: " + currentSize.charAt(0).toUpperCase() + currentSize.slice(1)
        const body = "Thickness: " + preset.panelThickness + "px | Margin: " + preset.panelMargin + "px\n" +
                     "Exclusive Zone: " + (preset.panelThickness + preset.panelMargin * 2) + "px"
        
        Notifications.send(summary, body, "HyprUI", "preferences-desktop-display")
    }

    // ─── Toggle helpers ───────────────────────────────────────────────────────
    function pinApp(appId) {
        if (!pinnedApps.includes(appId))
            pinnedApps = [...pinnedApps, appId]
    }

    function unpinApp(appId) {
        pinnedApps = pinnedApps.filter(app => app !== appId)
    }

    function toggleLauncher() {
        launcherVisible = !launcherVisible
        if (launcherVisible) { dashboardVisible = false; controlCenterVisible = false }
    }

    function toggleDashboard() {
        dashboardVisible = !dashboardVisible
        if (dashboardVisible) { launcherVisible = false; controlCenterVisible = false }
    }

    function toggleControlCenter() {
        controlCenterVisible = !controlCenterVisible
        if (controlCenterVisible) { launcherVisible = false; dashboardVisible = false }
    }
}
