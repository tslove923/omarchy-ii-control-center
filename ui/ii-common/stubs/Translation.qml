pragma Singleton
import Quickshell

// Stand-in for illogical-impulse's i18n Translation.qml singleton. This
// plugin ships English-only, so tr() is a genuine no-op passthrough --
// exactly what such a fallback shim should be. Qt's built-in String.arg()
// extension still works fine on the passed-through string.
Singleton {
    function tr(x) {
        return x;
    }
}
