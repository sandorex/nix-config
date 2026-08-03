import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu

import "SystemTray"

// Rectangle {
//     id: root
//
//     property bool menuOpen: false

    Repeater {
        model: SystemTray.items

        TrayItem {
            // onMenuOpened: root.menuOpen = true
            // onMenuClosed: root.menuOpen = false
        }
    }
// }
