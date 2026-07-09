import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

import qs
import qs.components

// TODO add a confirm dialog as an option
OverlayPopup {
    id: root

    required property var icons

    Rectangle {
        implicitWidth: layout.width + 35
        implicitHeight: layout.height + 20
        anchors.centerIn: parent
        color: Theme.colorBg
        radius: 30

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 25

        Repeater {
            model: icons

            Rectangle {
                height: 60
                width: 60
                radius: width / 2

                color: mouseArea.containsMouse ? Qt.lighter(Theme.colorBg, 2.25) : Theme.colorBg

                Text {
                    anchors.centerIn: parent

                    text: modelData.icon ?? "?"
                    color: Theme.colorFg
                    font.pixelSize: 32
                    font.family: Theme.fontFamily
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    onClicked: {
                        Quickshell.execDetached(modelData.exec)
                        root.close()
                    }
                }
            }
        }
    }
}
