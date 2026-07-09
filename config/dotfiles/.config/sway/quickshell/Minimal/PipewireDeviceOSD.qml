import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs

Scope {
    id: root

    Connections {
        target: Pipewire

        function onDefaultAudioSinkChanged() {
            root.isSink = true
            root.shouldShowOsd = true
            hideTimer.restart()
        }

        function onDefaultAudioSourceChanged() {
            root.isSink = false
            root.shouldShowOsd = true
            hideTimer.restart()
        }
    }

    property bool shouldShowOsd: false
    property bool isSink: false

    function getText(isSink) {
        let device = isSink ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
        let options = [ device.nickname, device.description, device.name, device.id ];

        // NOTE for some reason i could not get ?? operator to work properly here
        let name = "?"
        for (let i = 0; i < options.length; i++) {
            if (options[i]) {
                name = options[i]
                break
            }
        }

        return `${ isSink ? "󰓃 " : "󰍬 " } ${name}`
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0

            implicitWidth: 400
            implicitHeight: 50
            color: "transparent"

            // click through the window
            mask: Region {}

            // TODO its fugly
            Rectangle {
                id: rect
                anchors.fill: parent
                radius: height / 2
                color: Theme.colorBg

                Text {
                    anchors.centerIn: parent

                    text: root.getText(root.isSink)

                    color: Theme.colorFg

                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                }
            }
        }
    }
}
