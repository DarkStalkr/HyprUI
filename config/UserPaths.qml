import Quickshell
import Quickshell.Io

JsonObject {
    readonly property string home: Quickshell.env("HOME")
    property string wallpaperDir: `${home}/Pictures/Wallpapers`
    property string sessionGif: "root:/assets/kurukuru.gif"
    property string mediaGif: "root:/assets/bongocat.gif"
}
