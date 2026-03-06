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
            
            const item = {
                id: notif.id,
                summary: notif.summary,
                body: notif.body,
                appName: notif.appName,
                appIcon: notif.appIcon,
                image: notif.image,
                time: new Date(),
                notif: notif,
                expired: false
            };
            
            root.notifications = [item, ...root.notifications];
            
            // Auto-expire popup logic would go in the UI module
        }
    }
    
    function remove(id) {
        root.notifications = root.notifications.filter(n => n.id !== id);
    }
}
