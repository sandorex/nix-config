import QtQuick
import Quickshell

PanelWindow {
    required property var screen
    required property var win

    screen: screen

    // anchors { right: true; top: true }

    implicitWidth: 10
    implicitHeight: 10
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: win.visible = true
    }
}
