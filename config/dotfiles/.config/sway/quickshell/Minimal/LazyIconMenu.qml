import QtQuick
import Quickshell

Scope {
    id: root

    required property var icons
    property bool show: false

    // timer to hide after a delay
    Timer {
        id: timer
        interval: 350
        onTriggered: root.show = false
    }

    LazyLoader {
        active: root.show

        IconMenu {
            icons: root.icons
            onLostFocus: timer.restart()
            onGainedFocus: timer.stop()
            onClose: {
                timer.stop()
                root.show = false
            }
        }
    }
}
