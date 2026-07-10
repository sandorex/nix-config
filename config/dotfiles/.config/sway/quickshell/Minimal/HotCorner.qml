import QtQuick
import Quickshell

PanelWindow {
    id: root

    signal triggered()

    required property var screen

    screen: screen ?? null

    implicitWidth: 10
    implicitHeight: 10
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.triggered()
    }
}
