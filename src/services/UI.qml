pragma Singleton
import QtQuick

QtObject {
    property bool launcherVisible: false
    property bool dashboardVisible: false
    
    function toggleLauncher() {
        launcherVisible = !launcherVisible;
        if (launcherVisible) dashboardVisible = false;
    }

    function toggleDashboard() {
        dashboardVisible = !dashboardVisible;
        if (dashboardVisible) launcherVisible = false;
    }
}
