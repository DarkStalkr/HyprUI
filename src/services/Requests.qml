pragma Singleton
import QtQuick

QtObject {
    function get(url, callback, errorCallback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    if (callback) callback(xhr.responseText);
                } else {
                    if (errorCallback) errorCallback(xhr.statusText);
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }
}
