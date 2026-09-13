import QtQuick
import Quickshell
import "../../services"
import "../../"
import "../../stubs"

// Ported from ii's .../models/quickToggles/NotificationToggle.qml -- backend
// re-pointed at this plugin's Notifications service shim, which drives
// Omarchy's own DND command (`omarchy-shell notifications toggleDnd`).
QuickToggleModel {
    name: Translation.tr("Notifications")
    statusText: toggled ? Translation.tr("Show") : Translation.tr("Silent")
    toggled: !Notifications.silent
    icon: toggled ? "notifications_active" : "notifications_paused"

    mainAction: () => {
        Notifications.toggleSilent();
    }

    tooltipText: Translation.tr("Show notifications")
}
