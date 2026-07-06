import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import qs

RowLayout {
    spacing: 6

    Repeater {
        model: I3.workspaces

        Rectangle {
            id: rect

            width: 16
            height: 20

            property bool isFocused: I3.focusedWorkspace?.id === modelData.id

            // visible but not focused workspaces (basically workspaces on other monitors)
            property bool isVisible: !isFocused && I3.monitors.values.some((m) => modelData.id == m.activeWorkspace?.id)

            // highlights visible workspaces (the focused on will be brighter)
            color: isFocused
                ? "#5e81ac"
                : isVisible
                ? "#30455E"
                : "#202032"

            Text {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: rect.isFocused ? "#d8dee9" : "#7A7A7A"
                text: ` ${modelData.name} `
                font.pixelSize: rect.width
                font.family: Theme.fontFamily
            }

            // TODO right click swap workspace windows
            MouseArea {
                anchors.fill: parent
                onClicked: I3.dispatch("workspace " + modelData.name)
            }
        }
    }
}
