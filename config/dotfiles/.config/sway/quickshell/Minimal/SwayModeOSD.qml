import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Wayland
import qs

// show OSD while in non default mode
Scope {
    id: root

    readonly property string defaultMode: "default"
    property string mode: defaultMode

    I3IpcListener {
        subscriptions: ["mode"]
        onIpcEvent: function (e) {
            if (e.type === "mode") {
                root.mode = JSON.parse(e.data ?? "{}").change ?? root.defaultMode
            }
        }
    }

    LazyLoader {
        active: root.mode !== root.defaultMode

        PanelWindow {
            implicitWidth: 200
            implicitHeight: 100

            anchors.bottom: true
            margins.bottom: screen.height / 8
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore

            color: "transparent"

            // click through it as its OSD
            mask: Region {}

            Rectangle {
                anchors.centerIn: parent

                implicitWidth: text.width + 40
                implicitHeight: text.height
                radius: 10
                color: "black"

                Text {
                    id: text

                    anchors.centerIn: parent

                    text: root.mode

                    font.bold: true
                    font.family: Theme.fontFamily
                    font.pixelSize: 42
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 24
                    color: Theme.colorFg
                }
            }
        }
    }
}
