import QtQuick
import Quickshell
import qs.Ui
import qs.Commons

// Far-right bar icon for the ii Control Center. Clicking it toggles the
// `overlay`-kind entry point (ui/ControlCenter.qml) via the same
// `omarchy shell shell toggle <id> '{}'` CLI path first-party plugins use
// (see com.omastorm.radar's RadarBar.qml `expand()` for precedent) --
// bar-widget and overlay/panel entry points are separate host-managed
// surfaces, there's no direct QML reference between them.
BarWidget {
  id: root
  moduleName: "trevor.ii-control-center"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function toggle() {
    Quickshell.execDetached(["omarchy", "shell", "shell", "toggle", "trevor.ii-control-center", "{}"])
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: 27
    opticalSize: 16
    useActiveColor: false
    iconComponent: Component {
      Image {
        anchors.centerIn: parent
        source: "assets/illogical-impulse.svg"
        sourceSize.width: 16
        sourceSize.height: 16
        smooth: true
      }
    }
    onPressed: b => { if (b === Qt.LeftButton) root.toggle() }
  }
}
