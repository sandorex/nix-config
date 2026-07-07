// enables menu in systemtray
//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Wayland
import Quickshell.Widgets

import "Modules" as Modules

// TODO show OSD on volume change and workspace change!
// https://git.outfoxxed.me/quickshell/quickshell-examples/src/branch/master/volume-osd/shell.qml
ShellRoot {
    // TODO maybe hide all windows in sway so the backgronud becomes visible so i dont have to do fancy
    // tricks to show it?
    // PanelWindow {
    //     id: edgeTrigger
    //
    //     anchors { right: true; top: true }
    //
    //     implicitWidth: 10
    //     implicitHeight: 10
    //     color: "transparent"
    //
    //     MouseArea {
    //         anchors.fill: parent
    //         hoverEnabled: true
    //
    //         onEntered: mainWindow.visible = true
    //     }
    // }

    // PanelWindow {
    //     id: mainWindow
    //     visible: false
    //     implicitWidth: 300
    //     implicitHeight: 600
    //
    //     anchors { right: true; top: true }
    //
    //     // Handle hiding the window when the mouse leaves
    //     HoverHandler {
    //         onHoveredChanged: {
    //             if (!hovered) mainWindow.visible = false
    //         }
    //     }
    //
    //     // Window content
    //     Rectangle {
    //         anchors.fill: parent
    //         color: "black"
    //         Text {
    //             anchors.centerIn: parent
    //             color: "white"
    //             text: "Side Window"
    //         }
    //     }
    // }

    // TODO just load it on mouse in the corner so it does not to be visible on each monitor
    // shown on each monitor in the background
    Variants {
        model: Quickshell.screens

        Item {
            required property var modelData

            // TODO these could be abstracted?
            PanelWindow {
                screen: modelData

                anchors { right: true; top: true }

                implicitWidth: 10
                implicitHeight: 10
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: win.visible = true
                }
            }

            PanelWindow {
                screen: modelData

                anchors { right: true; bottom: true }

                implicitWidth: 10
                implicitHeight: 10
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: win.visible = true
                }
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

                // TODO remove this once OSD for workspace change works
                // show current workspace in the center
                Text {
                    // TODO I3.monitorFor does not work
                    property I3Monitor i3monitor: I3.monitors.values.find((m) => m.name === modelData.name)

                    anchors.centerIn: parent

                    text: i3monitor?.activeWorkspace?.name ?? "?"

                    color: Qt.rgba(1.0, 1.0, 1.0, 0.10)
                    font.pixelSize: 120
                    font.bold: true
                    font.family: Theme.fontFamily
                }

                // hide when mouse leaves edge of screen
                // MouseArea {
                //     anchors.right: parent.right
                //     anchors.top: parent.top
                //     anchors.bottom: parent.bottom
                //     width: 60
                //
                //     hoverEnabled: true
                //     onExited: win.visible = false
                // }

                Item {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 60

                    HoverHandler {
                        onHoveredChanged: {
                            if (!hovered) win.visible = false
                        }
                    }
                }

                // TODO add background here
                ColumnLayout {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 5

                    spacing: 10

                    // abstract this, maybe a repeater with json file for each exec command
                    Text {
                        color: "#cdd6f4"
                        font.pixelSize: 20
                        font.family: Theme.fontFamily

                        text: " 󱏊 " // 󱏊  - titlebars on / 󰓫 - titlebars off

                        MouseArea {
                            onClicked: console.log("first")
                        }
                    }

                    Text {
                        color: "#cdd6f4"
                        font.pixelSize: 20
                        font.family: Theme.fontFamily

                        text: " B "
                    }

                    Item { height: 40; }

                    Text {
                        color: "#cdd6f4"
                        font.pixelSize: 20
                        font.family: Theme.fontFamily

                        text: " 󰗽 "
                    }

                    Text {
                        color: "#cdd6f4"
                        font.pixelSize: 20
                        font.family: Theme.fontFamily

                        text: "  "
                    }

                    Text {
                        color: "#cdd6f4"
                        font.pixelSize: 20
                        font.family: Theme.fontFamily

                        text: "  "
                    }

                    Text {
                        color: "#cdd6f4"
                        font.pixelSize: 20
                        font.family: Theme.fontFamily

                        text: " 󰤄 "
                    }

                    Text {
                        color: "#cdd6f4"
                        font.pixelSize: 20
                        font.family: Theme.fontFamily

                        text: " 󰤆 "
                    }
                }

                ColumnLayout {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 5

                    spacing: 5

                    Modules.SystemTray {}
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

                Text {
                    id: clockText

                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: 5

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

                // // additional information
                // ColumnLayout {
                //     spacing: 4
                //     anchors.right: parent.right
                //     anchors.bottom: parent.bottom
                //
                //     Text {
                //         text: "Yes"
                //
                //         Layout.alignment: Qt.AlignRight
                //
                //         color: "white"
                //         font.pixelSize: 18
                //         font.family: Theme.fontFamily
                //     }
                //
                //     Text {
                //         text: "16h22m3s"
                //
                //         Layout.alignment: Qt.AlignRight
                //
                //         color: "white"
                //         font.pixelSize: 18
                //         font.family: Theme.fontFamily
                //     }
                // }
            }
        }
    }
}
