import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Transparent fullscreen window which will notify when mouse has gone outside of the window
// and when to close it
//
// Meant as a base for popups
PanelWindow {
    id: root

    // the window wants to close
    signal close()

    // the window has lost focus, close it if you wish
    signal lostFocus()

    // the window has regained focus, reset the close timer
    signal gainedFocus()

    // ignore first time so mouse can enter the window first (used for popups)
    property bool ignoreFirst: false

    // no background
    color: "transparent"

    // fullscreen window on top
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    exclusiveZone: 0

    // NOTE: mouse area that triggers the hide timer if mouse leaves but on second leave
    // cause when mouse is not in center the window will close before mouse reaches it
    MouseArea {
        property bool triggered: !root.ignoreFirst

        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            if (triggered) {
                root.lostFocus()
            } else {
                triggered = true
            }
        }

        // close imidiately on click
        onClicked: root.close()

        // stop timer if mouse entered the window again
        onExited: root.gainedFocus()

        // last priority
        z: -10
    }
}
