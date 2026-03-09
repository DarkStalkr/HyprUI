pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // UI States (reset on restart)
    property bool launcherVisible: false
    property bool dashboardVisible: false
    property bool controlCenterVisible: false

    // Alias directly into the JsonAdapter
    property alias pinnedApps: _adapter.pinnedApps

    property var _storage: FileView {
        path: Quickshell.statePath("pinnedApps.json")
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: _adapter
            property list<string> pinnedApps: ["librewolf", "kitty", "thunar", "vscodium"]
        }
    }

    Component.onCompleted: _storage.reload() // Added back for initial loading

    function pinApp(appId) {
        if (!pinnedApps.includes(appId))
            pinnedApps = [...pinnedApps, appId];
    }

    function unpinApp(appId) {
        pinnedApps = pinnedApps.filter(app => app !== appId);
    }

    function toggleLauncher() {
        launcherVisible = !launcherVisible;
        if (launcherVisible) { dashboardVisible = false; controlCenterVisible = false; }
    }

    function toggleDashboard() {
        dashboardVisible = !dashboardVisible;
        if (dashboardVisible) { launcherVisible = false; controlCenterVisible = false; }
    }

    function toggleControlCenter() {
        controlCenterVisible = !controlCenterVisible;
        if (controlCenterVisible) { launcherVisible = false; dashboardVisible = false; }
    }
}
