import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs

Scope {
    id: root

    // track the sink so volume is updated
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Connections {
        // NOTE: its important for this to be null if missing to prevent errors in console
        target: Pipewire.defaultAudioSink?.audio ?? null

        function onVolumeChanged() {
            root.shouldShowOsd = true
            hideTimer.restart()
        }

        // track muted state as well
        function onMutedChanged() {
            root.shouldShowOsd = true
            hideTimer.restart()
        }
    }

    property bool shouldShowOsd: false

    Timer {
        id: hideTimer
        interval: 800
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0

            implicitWidth: 300
            implicitHeight: 50
            color: "transparent"

            // click through the window
            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "#80000000"

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    Item { width: 2 }

                    Text {
                      text: Pipewire.defaultAudioSink?.audio?.muted ? "󰝟" : "󰕾"
                      color: Pipewire.defaultAudioSink?.audio?.muted ? "red" : Theme.colorFg

                      font.family: Theme.fontFamily
                      font.pixelSize: 32
                    }

                    Item { width: 2 }

                    Rectangle {
                        Layout.fillWidth: true

                        implicitHeight: 10
                        radius: 0
                        color: "#50ffffff"

                        // this rectangle is the 50% above 100% volume
                        Rectangle {
                            radius: parent.radius
                            color: Qt.darker(parent.color, 1.5)

                            width: parent.width * (1/3)

                            anchors {
                              top: parent.top
                              right: parent.right
                              bottom: parent.bottom
                            }
                        }

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            color: Pipewire.defaultAudioSink?.audio?.muted ? "red" : "white"

                            // scale down the volume as the max value is 150% (or raw 1.5)
                            implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0) * (2/3)
                            radius: parent.radius
                        }
                    }
                }
            }
        }
    }
}
