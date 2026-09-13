import QtQuick
import Quickshell
import "../../services"
import "../../"
import "../../stubs"

// Ported from ii's .../models/quickToggles/ScreenSnipToggle.qml. ii's version
// closes its sidebar then calls `qs ipc call region screenshot` (ii's own
// region-selector). There's no ii shell here, so per the port's "use Omarchy
// equivalents" rule the action runs Omarchy's native region-screenshot
// (`omarchy capture screenshot region copy` -- grim/slurp-based, copies the
// result to the clipboard, matching ii's default copy behavior).
QuickToggleModel {
    name: Translation.tr("Screen snip")
    hasStatusText: false
    toggled: false
    icon: "screenshot_region"

    mainAction: () => {
        GlobalStates.sidebarRightOpen = false;
        delayedActionTimer.start();
    }
    Timer {
        id: delayedActionTimer
        interval: 300
        repeat: false
        onTriggered: {
            Quickshell.execDetached(["omarchy", "capture", "screenshot", "region", "copy"]);
        }
    }

    tooltipText: Translation.tr("Screen snip")
}
