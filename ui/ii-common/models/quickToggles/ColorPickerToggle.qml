import QtQuick
import Quickshell
import "../../services"
import "../../"
import "../../stubs"

// Ported from ii's .../models/quickToggles/ColorPickerToggle.qml -- real
// backend (`hyprpicker -a`, installed by this plugin's setup.sh).
QuickToggleModel {
    name: Translation.tr("Color picker")
    hasStatusText: false
    toggled: false
    icon: "colorize"

    mainAction: () => {
        GlobalStates.sidebarRightOpen = false;
        delayedActionTimer.start();
    }
    Timer {
        id: delayedActionTimer
        interval: 300
        repeat: false
        onTriggered: {
            Quickshell.execDetached(["hyprpicker", "-a"]);
        }
    }

    tooltipText: Translation.tr("Color picker")
}
