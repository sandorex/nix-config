import Quickshell
import QtQuick
import qs

// simple abstraction so clickable icons are easy to do
Text {
    id: root

    property alias acceptedButtons: mouseArea.acceptedButtons
    property alias hoverEnabled: mouseArea.hoverEnabled
    property alias containsMouse: mouseArea.containsMouse

    signal leftClick()
    signal middleClick()
    signal rightClick()
    signal scrollUp()
    signal scrollDown()

    color: Theme.colorFg
    font.family: Theme.fontFamily
    font.pixelSize: 18

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        onClicked: (e) => {
            e.accepted = true

            if (e.button == Qt.LeftButton) {
                root.leftClick()
            } else if (e.button == Qt.MiddleButton) {
                root.middleClick()
            } else if (e.button == Qt.RightButton) {
                root.rightClick()
            }
        }

        onWheel: (e) => {
            e.accepted = true

            if (e.angleDelta.y > 0) {
                root.scrollUp()
            } else {
                root.scrollDown()
            }
        }
    }
}
