import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu

import "SystemTray"

Repeater {
    model: SystemTray.items

    delegate: TrayItem {}
}
