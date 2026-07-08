import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Wayland
import qs

// show OSD when workspace is switched
Scope {
    id: root

    property bool showWorkspace: false

    Timer {
        id: timer
        interval: 500
        onTriggered: root.showWorkspace = false
    }

    I3IpcListener {
        subscriptions: ["workspace"]
        onIpcEvent: function (e) {
            if (e.type === "workspace") {
                root.showWorkspace = true
                timer.restart()
            }
        }
    }

    LazyLoader {
        active: root.showWorkspace

        PanelWindow {
            implicitWidth: 200
            implicitHeight: 200

            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore

            color: "transparent"

            // click through it as its OSD
            mask: Region {}

            Rectangle {
                anchors.centerIn: parent

                implicitWidth: text.width + 40
                implicitHeight: text.height
                radius: 5
                color: "black"

                Text {
                    id: text

                    anchors.centerIn: parent

                    text: I3.focusedWorkspace?.name ?? "?"

                    font.pixelSize: 72
                    font.bold: true
                    font.family: Theme.fontFamily
                    color: Theme.colorFg
                }
            }
        }
    }
}

