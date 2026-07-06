import QtQuick
import Quickshell
import Quickshell.I3
import qs

Rectangle {
    property string mode: "default"

    id: "workspacesRoot"
    width: workspaces.implicitWidth
    height: workspaces.implicitHeight

    color: mode === "default" ? "transparent" : "#5E81AC"

    // listen when sway mode changes
    I3IpcListener {
        subscriptions: ["mode"]
        onIpcEvent: (e) => workspacesRoot.mode = JSON.parse(e.data ?? "{}").change ?? "default"
    }

    // overlay mode text
    Text {
        id: modeName
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.verticalCenter: parent.verticalCenter
        width: workspaces.implicitWidth

        color: Theme.colorFg

        font.family: Theme.fontFamily
        font.bold: true
        text: workspacesRoot.mode === "default" ? "" : workspacesRoot.mode
    }

    // the workspace buttons
    SwayWorkspaces {
        id: workspaces
        anchors.verticalCenter: parent.verticalCenter

        // hide workspaces when in different mode
        opacity: workspacesRoot.mode === "default" ? 1.0 : 0.0
    }
}
