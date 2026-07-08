import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs

// TODO its not closing properly..
Scope {
    id: root

    required property var buttons
    property bool show: false

    LazyLoader {
        active: root.show

        PanelWindow {
            id: win

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore
            focusable: true

            implicitWidth: layout.width + 35
            implicitHeight: layout.height + 20

            Rectangle {
                anchors.fill: parent
                color: Theme.colorBg
                radius: 30

                MouseArea {
                    anchors.fill: parent
                    onExited: {
                        console.log("egege")
                        root.show = false
                    }
                    onEntered: {
                        console.log("enter")
                    }
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
                            hoverEnabled: true
                            onClicked: {
                                console.log(modelData.exec) // TODO
                                root.show = false
                            }
                        }
                    }
                }
            }
        }
    }
}
