pragma Singleton
import Quickshell

// Shared drag-and-drop state for the Android quick-toggle grid's edit-mode
// reorder (see AndroidQuickToggleButton.qml / AndroidQuickPanel.qml). A
// singleton -- like Config/Translation/GlobalStates -- so any tile deep in
// the Repeater > ButtonGroup > Repeater > DelegateChooser > per-type-wrapper
// nesting can read/write it directly, instead of bubbling continuous
// pointer-move events back up through a dozen layers of thin wrapper
// components (one per toggle type).
Singleton {
    id: root

    // "" when no drag is in progress.
    property string sourceType: ""
    property string sourceIcon: ""
    // The type of the tile currently under the pointer, or "" if none.
    // Tiles set this themselves by comparing their own screen geometry
    // against globalX/globalY.
    property string hoverType: ""
    property real globalX: 0
    property real globalY: 0

    function begin(type, icon, gx, gy) {
        root.sourceType = type;
        root.sourceIcon = icon;
        root.hoverType = "";
        root.globalX = gx;
        root.globalY = gy;
    }

    function move(gx, gy) {
        root.globalX = gx;
        root.globalY = gy;
    }

    function end() {
        root.sourceType = "";
        root.sourceIcon = "";
        root.hoverType = "";
    }
}
