// enables menu in systemtray
//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import qs.components

import "Modules" as Modules
import "Minimal" as Minimal

ShellRoot {
    id: root

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

    Minimal.LazyBrightnessMenu {
        id: brightnessMenu
    }

    property bool showSidebar: false
    property bool canClose: true

    Timer {
        id: hideTimer
        interval: 350
        onTriggered: root.close()
    }

    function show() {
        root.showSidebar = true
    }

    function close() {
        if (root.canClose) {
            root.showSidebar = false
        }
    }

    LazyLoader {
        active: root.showSidebar

        Minimal.Sidebar {
            onClose: root.close()
            onLostFocus: hideTimer.restart()
            onGainedFocus: hideTimer.stop()
            onItemClicked: (item) => {
                switch (item) {
                    case "power":
                        powerMenu.show = true
                        break;
                    case "brightness":
                        brightnessMenu.show = true
                        break;
                    default:
                }
            }
            onCanCloseChanged: (val) => root.canClose = val
        }
    }

    // add hotcorners to each monitor
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
                onTriggered: root.show()
            }

            Minimal.HotCorner {
                anchors {
                    bottom: true
                    right: true
                }

                screen: modelData
                onTriggered: root.show()
            }
        }
    }
}
