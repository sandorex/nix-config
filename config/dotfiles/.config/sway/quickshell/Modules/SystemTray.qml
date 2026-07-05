import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu

import "SystemTray"

// TODO add wrapper
Repeater {
    model: SystemTray.items

    delegate: TrayItem {}
}
