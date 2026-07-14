import QtQuick
import Quickshell

Scope {
    id: root

    property bool show: false

    // timer to hide after a delay
    Timer {
        id: timer
        interval: 350
        onTriggered: root.show = false
    }

    LazyLoader {
        active: root.show

        BrightnessMenu {
            onLostFocus: timer.restart()
            onGainedFocus: timer.stop()
            onClose: {
                timer.stop()
                root.show = false
            }
        }
    }
}
