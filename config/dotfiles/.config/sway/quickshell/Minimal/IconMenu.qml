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

            ClickableIconHoverable {
                text: modelData.icon ?? "?"
                font.pixelSize: 32
                onLeftClick: {
                    Quickshell.execDetached(modelData.exec)
                    root.close()
                }
            }
        }
    }
}
