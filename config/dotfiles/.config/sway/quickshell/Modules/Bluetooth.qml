import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs

MouseArea {
    id: mouseArea

    implicitWidth: text.implicitWidth
    implicitHeight: text.implicitHeight

    visible: Bluetooth.defaultAdapter !== undefined

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    //
    // onClicked: (e) => {
    //     e.accepted = true
    //
    //     if (e.button == Qt.MiddleButton) {
    //         Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    //     }
    // }
    //
    Text {
        // readonly property int volume: Math.round(Pipewire.defaultAudioSink?.audio?.volume ?? 0 * 100)
        // readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

        id: text

        anchors.verticalCenter: parent.verticalCenter
        padding: 6

        text: Bluetooth.defaultAdapter?.state === BluetoothAdapterState.ENABLED
            ? Bluetooth.devices.values.length == 0
                ? "󰂯"
                : "󰂱"
            : "󰂲"

        font.family: Theme.fontFamily
        font.pixelSize: 16
        // color: muted ? "red" : "white"
    }
}
