pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

// Trimmed from illogical-impulse's services/DateTime.qml -- the original is
// a general date/time string formatter reading five different
// Config.options.time.* format strings plus GlobalStates.screenLocked (for
// per-second vs per-minute clock precision) and a live /proc/uptime reader.
// Only collapsedCalendarFormat is referenced by the vendored
// BottomWidgetGroup.qml closure (its collapsed-row summary text), so
// everything else is dropped and the format itself is hardcoded to ii's own
// default rather than routed through Config.
Singleton {
    property var clock: SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    property string collapsedCalendarFormat: Qt.locale().toString(clock.date, "dddd, MMMM dd")
}
