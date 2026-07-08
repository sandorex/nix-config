import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs

Scope {
    id: root

    required property var buttons
    property bool show: false

    LazyLoader {
        active: root.show

        // TODO this could be abstracted into its own file, as i plan to use it for many things
        PanelWindow {
            id: win

            // no background
            color: "transparent"

            // fullscreen
            anchors { top: true; bottom: true; left: true; right: true }
            WlrLayershell.layer: WlrLayer.Overlay
            exclusiveZone: 0

            // triggers on second enter (so mouse can get to the window)
            MouseArea {
                property bool triggered: false

                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (triggered) {
                        root.show = false
                        triggered = false
                    } else {
                        triggered = true
                    }
                }

                // last priority
                z: -10
            }

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
                    model: buttons

                    Rectangle {
                        height: 60
                        width: 60
                        radius: 30

                        color: mouseArea.containsMouse ? Qt.lighter(Theme.colorBg, 1.80) : Theme.colorBg

                        Text {
                            anchors.centerIn: parent

                            text: modelData.icon
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
                                root.show = false
                            }
                        }
                    }
                }
            }
        }
    }
}
