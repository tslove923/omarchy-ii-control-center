pragma Singleton
import Quickshell

// Light shim for ii's services/AppSearch.qml. The only bits VolumeMixerEntry
// reads are guessIcon(name) (map a pipewire application/node name to a
// best-guess icon name) and iconExists(icon) (whether that icon actually
// resolves) -- porting ii's full desktop-entry indexing/fuzzy-search service
// is out of scope for a volume mixer, so this just always reports "no icon",
// which degrades gracefully to a blank/muted-glyph-only entry row.
Singleton {
    function guessIcon(name) {
        return "";
    }
    function iconExists(icon) {
        return false;
    }
}
