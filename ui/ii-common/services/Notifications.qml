pragma Singleton
import QtQuick
import Quickshell

// Shim for ii's services/Notifications.qml, exposing only `silent` — the
// one property the vendored NotificationToggle.qml model reads. ii's real
// Notifications service is a Quickshell NotificationsModel wrapper with a
// `silent` flag that the shell's notification daemon honors directly.
// Omarchy has no equivalent in-process flag this plugin can bind to, so
// this shim drives Omarchy's own DND command (`omarchy-shell notifications
// toggleDnd`) and mirrors the resulting state in `silent.
//
// Fidelity note (flagged per the port's "use Omarchy equivalents, note gaps"
// rule): `silent` reflects only toggles made through THIS button, not DND
// state set from elsewhere (e.g. the bar's own DND indicator), because there
// is no stable query for the current DND state short of the command's own
// side effects. Good enough for the toggle's on/off affordance.
Singleton {
    id: root
    property bool silent: false

    function toggleSilent() {
        root.silent = !root.silent
        Quickshell.execDetached(["omarchy-shell", "notifications", "toggleDnd"])
    }
}
