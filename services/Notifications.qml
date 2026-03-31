pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property list<var> notifications: []
    property bool dnd: false

    NotificationServer {
        id: server
        
        onNotification: notif => {
            if (root.dnd) return;
            
            console.log(`[Notifications] Received from ${notif.appName}: ${notif.summary}`);
            
            const item = {
                id: notif.id,
                summary: notif.summary,
                body: notif.body,
                appName: notif.appName,
                appIcon: notif.appIcon,
                image: notif.image || (notif.hints && notif.hints["image-path"]) || "",
                time: new Date(),
                expired: false
            };
            
            root.notifications = [item, ...root.notifications];
        }
    }
    
    // Internal function to trigger a UI notification
    function send(summary, body, appName = "HyprUI", appIcon = "preferences-desktop-theme") {
        const item = {
            id: Math.floor(Math.random() * 100000),
            summary: summary,
            body: body,
            appName: appName,
            appIcon: appIcon,
            time: new Date(),
            expired: false
        };
        root.notifications = [item, ...root.notifications];
    }
    
    function remove(id) {
        root.notifications = root.notifications.filter(n => n.id !== id);
    }
}
