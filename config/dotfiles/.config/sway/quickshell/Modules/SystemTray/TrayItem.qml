import QtQuick
import Quickshell

MouseArea {
    id: root

    required property var modelData
    property string rawIconName: modelData && modelData.icon ? String(modelData.icon) : ""

    implicitWidth: 30
    implicitHeight: 30

    // hoverEnabled: true
    property bool menuOpening: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: (event) => {
        if (event.button === Qt.LeftButton) {
            modelData.activate();
        } else if (event.button === Qt.RightButton) {
            if (menuAnchor.menu) {
                root.menuOpening = true
                openMenuTimer.restart()
            }
        }
    }

    Timer {
        id: openMenuTimer
        interval: 90
        repeat: false
        onTriggered: {
            menuAnchor.open()
            root.menuOpening = false
        }
    }

    QsMenuAnchor {
        id: menuAnchor
        menu: modelData.menu
        anchor.item: root
    }

    Image {
        id: content
        anchors.centerIn: parent
        width: 18
        height: 18

        cache: true
        asynchronous: false
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true

        source: {
            const raw = root.rawIconName;

            if (!raw) {
                return "image://icon/application-x-executable";
            }

            if (raw.startsWith("image://") || raw.startsWith("/") || raw.startsWith("file:")) {
                return raw;
            }

            if (raw.indexOf("spotify") !== -1) {
                return "image://icon/spotify";
            }

            if (raw === "nm-connection-editor") {
                return "image://icon/preferences-system-network";
            }

            return "image://icon/" + raw.replace(/-symbolic$/, "");
        }

        scale: root.menuOpening ? 1.12 : (root.containsMouse ? 1.06 : 1.0)
        opacity: 1.0
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }
}
