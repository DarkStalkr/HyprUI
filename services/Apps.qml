pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    function search(query) {
        if (!query) return [...DesktopEntries.applications.values];
        
        let lowerQuery = query.toLowerCase();
        return [...DesktopEntries.applications.values].filter(app => {
            return (app.name && app.name.toLowerCase().includes(lowerQuery)) ||
                   (app.genericName && app.genericName.toLowerCase().includes(lowerQuery)) ||
                   (app.comment && app.comment.toLowerCase().includes(lowerQuery));
        }).sort((a, b) => {
            // Priority: name starts with query > name contains query
            let aStarts = a.name.toLowerCase().startsWith(lowerQuery);
            let bStarts = b.name.toLowerCase().startsWith(lowerQuery);
            if (aStarts && !bStarts) return -1;
            if (!aStarts && bStarts) return 1;
            return a.name.localeCompare(b.name);
        });
    }

    function launch(app) {
        if (app && app.command) {
            Quickshell.execDetached(app.command);
        }
    }
}
