import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Bluetooth
import Quickshell.Services.SystemTray
import "../Modules" as Modules
import qs
import qs.components

OverlayPopup {
    id: root

    signal canCloseChanged(bool value)
    signal itemClicked(string item)

    // spawn on right side (otherwise spawns on left)
    property bool rightSide: true

    // attach to right side
    Rectangle {
        id: sidebar

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: root.rightSide ? parent.right : undefined
            left: root.rightSide ? undefined : parent.left
        }

        implicitWidth: 50

        color: "black"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        // quick action icons
        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 15

            spacing: 20

            Repeater {
                model: options.icons

                ClickableIconHoverable {
                    Layout.alignment: Qt.AlignHCenter

                    font.pixelSize: 20
                    text: modelData.icon

                    backgroundColor: "transparent"

                    width: 35
                    height: 35

                    onLeftClick: Quickshell.execDetached(modelData.exec)
                }
            }

            ClickableIconHoverable {
                Layout.alignment: Qt.AlignHCenter

                font.pixelSize: 20
                text: "󰃠"

                backgroundColor: "transparent"

                width: 35
                height: 35

                onLeftClick: {
                    root.close()
                    root.itemClicked("brightness")
                }
            }

            // power icon opens the power menu
            ClickableIconHoverable {
                Layout.alignment: Qt.AlignHCenter

                font.pixelSize: 20
                text: "󰤆"

                backgroundColor: "transparent"

                width: 35
                height: 35

                onLeftClick: {
                    root.close()
                    root.itemClicked("power")
                }
            }
        }

        // tray time etc
        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5

            spacing: 10

            Repeater {
                model: SystemTray.items

                TrayItem {
                    Layout.alignment: Qt.AlignHCenter

                    // prevents closing while menu is open
                    onMenuOpened: root.canCloseChanged(false)
                    onMenuClosed: root.canCloseChanged(true)
                }
            }

            Modules.Volume {
                Layout.alignment: Qt.AlignHCenter
                width: 30
                height: 30
            }

            ClickableIcon {
                Layout.alignment: Qt.AlignHCenter
                width: 30
                height: 30

                // hide unless there is bluetooth
                visible: Bluetooth.defaultAdapter

                font.pixelSize: 20
                text: BluetoothAdapterState.toString(Bluetooth.defaultAdapter?.state) == "Enabled"
                    ? Bluetooth.devices.values.length == 0
                        ? "󰂯"
                        : "󰂱"
                    : "󰂲"

                // TODO disable on middle click
                // right click open some kind of gui, overskride?
                // left click open rofi bluetooth script
                onLeftClick: {
                    console.log("bluetooth")
                }
            }

            Column {
                Layout.alignment: Qt.AlignHCenter

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: Qt.formatDateTime(clock.date, "hh:mm")

                    color: "#cdd6f4"
                    font.pixelSize: 16
                    font.bold: true
                    font.family: Theme.fontFamily
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: Qt.formatDateTime(clock.date, "dd/MM")

                    color: "#cdd6f4"
                    font.pixelSize: 12
                    font.bold: true
                    font.family: Theme.fontFamily
                }
            }
        }
    }
}
