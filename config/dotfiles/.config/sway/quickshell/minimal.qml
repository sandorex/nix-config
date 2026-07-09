// enables menu in systemtray
//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Bluetooth
import Quickshell.Services.SystemTray

import qs.components

import "Modules" as Modules
import "Minimal" as Minimal

ShellRoot {
    // global clock that updates every minute
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // load icons from static file
    readonly property var options: JSON.parse(jsonFile.text())
    FileView {
        id: jsonFile
        path: Qt.resolvedUrl("./minimal.json")
        blockLoading: true
    }

    // OSDs for nicer experience
    Minimal.SwayWorkspaceOSD {}
    Minimal.SwayModeOSD {}
    Minimal.PipewireVolumeOSD {}
    Minimal.PipewireDeviceOSD {}

    Minimal.LazyIconMenu {
        id: powerMenu
        icons: options.powerIcons
    }

    // TODO use lazyloader for the sidebar and just put activators on each monitor
    Variants {
        model: Quickshell.screens

        Item {
            required property var modelData

            Minimal.HotCorner {
                anchors {
                    top: true
                    right: true
                }

                screen: modelData
                win: win
            }

            Minimal.HotCorner {
                anchors {
                    bottom: true
                    right: true
                }

                screen: modelData
                win: win
            }

            Timer {
                id: winHideTimer
                interval: 350
                onTriggered: win.visible = false
            }

            // TODO could possibly be a OverlayPopup?
            PanelWindow {
                id: win

                property bool menuOpen: false

                screen: modelData

                // fullscreen window
                anchors { top: true; bottom: true; left: true; right: true }

                visible: false
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Overlay
                exclusionMode: ExclusionMode.Ignore

                // hide with the delay when outside the bar
                // NOTE: this was done cause opening a systemtray menu caused it to hide
                Item {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.left: parent.left

                    anchors.rightMargin: sidebar.width

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: {
                            if (!win.menuOpen) {
                                winHideTimer.restart()
                            }
                        }
                        onExited: winHideTimer.stop()
                        onClicked: win.visible = false
                    }
                }

                Rectangle {
                    id: sidebar

                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    implicitWidth: 50

                    color: "black"

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

                        // power icon opens the power menu
                        ClickableIconHoverable {
                            Layout.alignment: Qt.AlignHCenter

                            font.pixelSize: 20
                            text: "󰤆"

                            backgroundColor: "transparent"

                            width: 35
                            height: 35

                            onLeftClick: {
                                win.visible = false
                                powerMenu.show = true
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5

                        spacing: 10

                        Repeater {
                            model: SystemTray.items

                            TrayItem {
                                Layout.alignment: Qt.AlignHCenter

                                onMenuOpened: win.menuOpen = true
                                onMenuClosed: win.menuOpen = false
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
                            text: Bluetooth.defaultAdapter?.state === BluetoothAdapterState.ENABLED
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
        }
    }
}
