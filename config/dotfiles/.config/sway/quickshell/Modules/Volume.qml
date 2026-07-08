import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs

MouseArea {
    // how much is volume increased / decreased on each scroll
    property int volumeIncrement: 2

    id: mouseArea

    implicitWidth: text.implicitWidth
    implicitHeight: text.implicitHeight

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    // TODO open mixer/chooser on left click?
    onClicked: (e) => {
        e.accepted = true

        if (e.button == Qt.MiddleButton) {
            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        }
    }

    onWheel: (e) => {
        e.accepted = true

        let vol = ""
        if (e.angleDelta.y > 0) {
            vol = "+"
        } else {
            vol = "-"
        }

        Quickshell.execDetached(["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", `${volumeIncrement}%${vol}`])
    }

    Text {
        property int volume: Math.round((Pipewire.defaultAudioSink?.audio?.volume ?? 0) * 100)
        property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

        id: text

        anchors.verticalCenter: parent.verticalCenter

        text: mouseArea.containsMouse
            ? `${volume}%`
            : muted
            ? "󰖁"
            : "󰕾"

        font.family: Theme.fontFamily
        font.pixelSize: 18
        color: muted ? "red" : "white"
    }
}

