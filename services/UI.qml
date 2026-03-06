pragma Singleton
import QtQuick

QtObject {
    property bool launcherVisible: false
    property bool dashboardVisible: false
    property bool controlCenterVisible: false
    property var pinnedApps: ["librewolf", "kitty", "thunar", "vscodium"]
    
    function pinApp(appId) {
        if (!pinnedApps.includes(appId)) {
            pinnedApps = [...pinnedApps, appId];
        }
    }
    
    function toggleLauncher() {
        launcherVisible = !launcherVisible;
        if (launcherVisible) {
            dashboardVisible = false;
            controlCenterVisible = false;
        }
    }

    function toggleDashboard() {
        dashboardVisible = !dashboardVisible;
        if (dashboardVisible) {
            launcherVisible = false;
            controlCenterVisible = false;
        }
    }

    function toggleControlCenter() {
        controlCenterVisible = !controlCenterVisible;
        if (controlCenterVisible) {
            launcherVisible = false;
            dashboardVisible = false;
        }
    }
}
