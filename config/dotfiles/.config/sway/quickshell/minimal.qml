// enables menu in systemtray
//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.I3
import Quickshell.Wayland
import Quickshell.Widgets

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

    Minimal.PowerMenu {
        id: powerMenu
        buttons: options.powerIcons
    }

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

            PanelWindow {
                id: win

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

                        onEntered: winHideTimer.restart()
                        onExited: winHideTimer.stop()
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

                            Text {
                                Layout.alignment: Qt.AlignHCenter

                                color: "#cdd6f4"
                                font.pixelSize: 20
                                font.family: Theme.fontFamily

                                text: modelData.icon

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: console.log(modelData.exec)
                                }
                            }
                        }

                        // TODO just make the power icon open a dialog with options
                        Text {
                            Layout.alignment: Qt.AlignHCenter

                            color: "#cdd6f4"
                            font.pixelSize: 20
                            font.family: Theme.fontFamily

                            text: "󰤆"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    win.visible = false
                                    powerMenu.show = true
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5

                        spacing: 10

                        Column {
                            Layout.alignment: Qt.AlignHCenter

                            spacing: parent.spacing

                            Modules.SystemTray {}
                        }

                        Modules.Volume {
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter

                            color: "#cdd6f4"
                            font.pixelSize: 20
                            font.family: Theme.fontFamily

                            text: "󰂯"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: console.log(modelData.exec)
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter

                            color: "#cdd6f4"
                            font.pixelSize: 18
                            font.family: Theme.fontFamily

                            text: "󰃠"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: console.log(modelData.exec)
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

                // TODO make it blend into background more, maybe grayscale effect?
                // global taskbar cause why not
                // RowLayout {
                //     anchors.bottom: parent.bottom
                //     anchors.horizontalCenter: parent.horizontalCenter
                //
                //     spacing: 5
                //
                //     Repeater {
                //         model: ToplevelManager.toplevels
                //
                //         Item {
                //             width: 32
                //             height: 32
                //
                //             // TODO show title on hover
                //             // TODO hover effect
                //             // TODO right click menu?
                //             MouseArea {
                //                 anchors.fill: parent
                //                 onClicked: {
                //                     modelData.activate()
                //                 }
                //             }
                //
                //             IconImage {
                //                 anchors.centerIn: parent
                //                 width: 24
                //                 height: 24
                //
                //                 // find icon from the toplevel name
                //                 source: {
                //                     if (!modelData.appId) return Quickshell.iconPath("application-x-executable");
                //
                //                     let entry = DesktopEntries.heuristicLookup(modelData.appId);
                //                     if (entry && entry.icon) {
                //                         let path = Quickshell.iconPath(entry.icon, true);
                //                         if (path) return path;
                //                     }
                //
                //                     // Fixes "org.qbittorrent.qBittorrent" -> "qbittorrent"
                //                     let cleanId = modelData.appId.toLowerCase();
                //                     if (cleanId.includes(".")) {
                //                         let parts = cleanId.split(".");
                //                         cleanId = parts[parts.length - 1];
                //                     }
                //
                //                     let pathFromCleanId = Quickshell.iconPath(cleanId, true);
                //                     if (pathFromCleanId) return pathFromCleanId;
                //
                //                     if (modelData.title) {
                //                         let titleEntry = DesktopEntries.heuristicLookup(modelData.title);
                //                         if (titleEntry && titleEntry.icon) {
                //                             let pathFromTitle = Quickshell.iconPath(titleEntry.icon, true);
                //                             if (pathFromTitle) return pathFromTitle;
                //                         }
                //                     }
                //
                //                     return Quickshell.iconPath("application-x-executable");
                //                 }
                //             }
                //         }
                //     }
                // }
            }
        }
    }
}
