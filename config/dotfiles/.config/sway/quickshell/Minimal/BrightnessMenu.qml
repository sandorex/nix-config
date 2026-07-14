// just copy kde brightness menu, primarly for ddcutil

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs
import qs.components

OverlayPopup {
    id: root

    triggered: false

    Rectangle {
        anchors.centerIn: parent
        width: 370
        implicitHeight: layout.height + 20
        radius: 20

        color: Theme.colorBg

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        ColumnLayout {
            id: layout

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 20

            Text {
                Layout.alignment: Qt.AlignHCenter

                text: 'Monitor Brightness'
                color: Theme.colorFg
                font.family: Theme.fontFamily
                font.pixelSize: 20
                renderType: Text.NativeRendering
            }

            Repeater {
                model: Quickshell.screens

                Row {
                    id: item
                    spacing: 10

                    Layout.alignment: Qt.AlignHCenter

                    property var value: null

                    // delays setting brightness as its slow and shouldnt be done often
                    Timer {
                        id: delayTimer
                        interval: 1000
                        onTriggered: Quickshell.execDetached(["ddcutil", "-l", modelData.model, "setvcp", "10", control.value])
                    }

                    Process {
                        id: ddcutilProcess
                        // NOTE i wanted to use serialNumber but its missing, at least on KDE Plasma
                        command: ["ddcutil", "-l", modelData.model, "-t", "getvcp", "10"]
                        running: true

                        stdout: SplitParser {
                            onRead: data => {
                                if (!data) return

                                // data is in format like: VCP 10 C 30 100
                                const splitData = Array.from(data.split(" "));

                                const val = parseInt(splitData[3]);
                                const maximum = parseInt(splitData[4]);

                                item.value = {
                                    current: val,
                                    max: maximum,
                                }
                            }
                        }
                    }

                    Text {
                        width: 150

                        text: `${modelData.model} (${modelData.name})`
                        color: Theme.colorFg
                        font.family: Theme.fontFamily
                        font.pixelSize: 16

                        renderType: Text.NativeRendering

                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }

                    Slider {
                        id: control

                        width: 150

                        // disable if the values are not loaded
                        enabled: item.value

                        snapMode: Slider.SnapAlways
                        from: 0
                        value: item.value?.current ?? 0
                        to: item.value?.max ?? 100
                        stepSize: 5

                        // every time it moves restart the timer
                        onMoved: delayTimer.restart()

                        background: Rectangle {
                            x: control.leftPadding
                            y: control.topPadding + control.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 16
                            width: control.availableWidth
                            height: implicitHeight
                            radius: height / 2
                            color: item.value ? "#bdbebf" : "gray"

                            Rectangle {
                                width: control.visualPosition * parent.width
                                height: parent.height
                                color: Qt.lighter(parent.color, 3.0)
                                radius: parent.radius
                            }
                        }

                        // i do not want the handle
                        handle: Item {}

                        // add scroll functionality
                        MouseArea {
                            anchors.fill: parent
                            propagateComposedEvents: true

                            onPressed: (e) => e.accepted = false
                            onWheel: (e) => {
                                e.accepted = true

                                // control.stepSize controls the step
                                if (e.angleDelta.y > 0) {
                                    control.increase()
                                } else {
                                    control.decrease()
                                }

                                // reset the timer
                                delayTimer.restart()
                            }
                        }
                    }

                    Text {
                        text: `${control.value}%`
                        color: Theme.colorFg
                        font.family: Theme.fontFamily
                        font.pixelSize: 16
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }
}
