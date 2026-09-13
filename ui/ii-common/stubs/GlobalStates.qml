pragma Singleton
import Quickshell

// Stand-in for illogical-impulse's GlobalStates.qml singleton (lives at the
// ii shell root, reachable there via the implicit "qs" module). Only
// sidebarRightOpen is referenced by the vendored closure (toggles' altAction
// close the real ii sidebar after launching an external app) -- this
// plugin's own sidebar visibility is actually driven by ControlCenter.qml's
// `opened` property, not this, so writes here are inert by design.
Singleton {
    property bool sidebarRightOpen: true
}
