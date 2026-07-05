import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import qs

RowLayout {
    Repeater {
        model: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

        Rectangle {
            width: 22
            height: 20

            property bool isFocused: I3.focusedWorkspace?.name === modelData

            // highlights current workspace
            color: isFocused
                ? "#5e81ac"
                : "#4c566a"

            Text {
                anchors.centerIn: parent
                color: "#d8dee9"
                text: `${modelData}`
                font.pixelSize: 14
                font.family: Theme.fontFamily
            }

            // TODO right click swap windows
            MouseArea {
                anchors.fill: parent
                onClicked: I3.dispatch("workspace " + modelData)
            }
        }
    }
}
