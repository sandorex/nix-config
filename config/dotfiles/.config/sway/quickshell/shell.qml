// enables menu in systemtray
//@ pragma UseQApplication

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.I3
import Quickshell.Widgets

// TODO make this a namespace Modules so its clear which are my modules
import "Modules"

PanelWindow {
    // top panel
    anchors { top: true; left: true; right: true }
    implicitHeight: 32
    color: Theme.colorBg

    // left
    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 6
        spacing: 4

        SwayWorkspacesExtra {}
    }

    // center
    Row {
        anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "Placeholder"
            font.family: Theme.fontFamily
            color: Theme.colorFg
        }
    }

    // right
    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10

        spacing: 6

        Volume {}

        Rectangle {
            implicitHeight: 34
            implicitWidth: trayRow.implicitWidth
            border.width: 0
            color: "transparent"

            Row {
                anchors.verticalCenter: parent.verticalCenter
                id: trayRow
                spacing: 5

                SystemTray {}
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            id: clockText
            color: "#cdd6f4"
            font.pixelSize: 16
            font.family: Theme.fontFamily

            Timer {
                interval: 10000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "dd/MM hh:mm")
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            // TODO find better icon
            font.family: Theme.fontFamily
            text: "󰇙"
            color: Theme.colorFg
        }
    }
}
