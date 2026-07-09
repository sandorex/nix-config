import Quickshell
import QtQuick
import qs

// simple abstraction so clickable icons are easy to do
Rectangle {
    id: root

    property alias acceptedButtons: mouseArea.acceptedButtons
    property alias hoverEnabled: mouseArea.hoverEnabled
    property alias containsMouse: mouseArea.containsMouse
    property alias text: text.text
    property alias textColor: text.color
    property alias font: text.font

    property color backgroundColor: Theme.colorBg
    property color backgroundColorHover: Qt.lighter(Theme.colorBg, 2.25)

    signal leftClick()
    signal middleClick()
    signal rightClick()
    signal scrollUp()
    signal scrollDown()

    width: 60
    height: 60
    radius: width / 2

    // simple hover effect
    color: mouseArea.containsMouse ? backgroundColorHover : backgroundColor

    Text {
        id: text

        anchors.centerIn: parent

        color: Theme.colorFg
        font.family: Theme.fontFamily
        font.pixelSize: 18
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

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
