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

// TODO show OSD on volume change and workspace change!
// https://git.outfoxxed.me/quickshell/quickshell-examples/src/branch/master/volume-osd/shell.qml
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

    // TODO this needs to be its own file
    // show OSD when workspace is switched
    Scope {
        id: workspaceOSD

        property bool showWorkspace: false

        Timer {
            id: workspaceOSDTimer
            interval: 500
            onTriggered: workspaceOSD.showWorkspace = false
        }

        I3IpcListener {
            subscriptions: ["workspace"]
            onIpcEvent: function (e) {
                if (e.type === "workspace") {
                    workspaceOSD.showWorkspace = true
                    workspaceOSDTimer.restart()
                }
            }
        }

        LazyLoader {
            active: workspaceOSD.showWorkspace

            PanelWindow {
                implicitWidth: 200
                implicitHeight: 200

                WlrLayershell.layer: WlrLayer.Overlay
                exclusionMode: ExclusionMode.Ignore

                color: "transparent"

                // click through it as its OSD
                mask: Region {}

                Rectangle {
                    anchors.centerIn: parent

                    implicitWidth: osdText.width + 40
                    implicitHeight: osdText.height
                    radius: 5
                    color: "black"

                    Text {
                        id: osdText

                        anchors.centerIn: parent

                        text: I3.focusedWorkspace?.name ?? "?"

                        font.pixelSize: 72
                        font.bold: true
                        font.family: Theme.fontFamily
                        color: "white"
                    }
                }
            }
        }
    }

    Scope {
        id: modeOSD

        property string mode: "default"

        I3IpcListener {
            subscriptions: ["mode"]
            onIpcEvent: function (e) {
                if (e.type === "mode") {
                    modeOSD.mode = JSON.parse(e.data ?? "{}").change ?? "default"
                }
            }
        }

        LazyLoader {
            active: modeOSD.mode !== "default"

            PanelWindow {
                implicitWidth: 200
                implicitHeight: 100

                anchors.bottom: true
                margins.bottom: screen.height / 8
                WlrLayershell.layer: WlrLayer.Overlay
                exclusionMode: ExclusionMode.Ignore

                color: "transparent"

                // click through it as its OSD
                mask: Region {}

                Rectangle {
                    anchors.centerIn: parent

                    implicitWidth: modeOSDText.width + 40
                    implicitHeight: modeOSDText.height
                    radius: 10
                    color: "black"

                    Text {
                        id: modeOSDText

                        anchors.centerIn: parent

                        text: modeOSD.mode

                        font.bold: true
                        font.family: Theme.fontFamily
                        font.pixelSize: 42
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 24
                        color: "white"
                    }
                }
            }
        }
    }

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

                // show current workspace in the center
                Text {
                    anchors.centerIn: parent

                    text: I3.focusedWorkspace?.name ?? "?"

                    color: Qt.rgba(1.0, 1.0, 1.0, 0.10)
                    font.pixelSize: 120
                    font.bold: true
                    font.family: Theme.fontFamily
                }

                // limit the hover handler to the right edge of screen
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

                Rectangle {
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

                        Item { height: 10; }

                        // TODO make the power icons collapsed by default or smth they ugly
                        Repeater {
                            model: options.powerIcons

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
                    }

                    ColumnLayout {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5

                        spacing: 5

                        Column {
                            Layout.alignment: Qt.AlignHCenter

                            spacing: 5

                            Modules.SystemTray {}
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
