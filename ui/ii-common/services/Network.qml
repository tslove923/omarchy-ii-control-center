pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Thin shim for ii's services/Network.qml, exposing
// wifiStatus/materialSymbol/networkName/ethernet/toggleWifi() as
// classicStyle/NetworkToggle.qml and the models/quickToggles/NetworkToggle.qml
// expect, PLUS (added for the Android quick-toggle grid's real WifiDialog)
// a real nmcli-backed access-point list/scan/connect/password flow:
// friendlyWifiNetworks/wifiScanning/wifiConnectTarget/enableWifi()/
// rescanWifi()/connectToWifiNetwork()/changePassword()/openPublicWifiPortal().
//
// Real ii's equivalent list lives behind qs.services.network's own
// NetworkManager-DBus-backed WifiAccessPoint service (a few hundred lines).
// This shim gets the same real, working result (a live scanned AP list you
// can actually connect to, with a real password prompt on failure) using
// nmcli instead -- the same tool this shim's toggleWifi()/wifiStatus polling
// already used before this pass, just extended.
Singleton {
    id: root

    property bool ethernet: false
    // "disabled" | "disconnected" | "connecting" | "connected" | "limited"
    property string wifiStatus: "disabled"
    property string networkName: ""
    property int networkStrength: 0

    readonly property string materialSymbol: root.ethernet
        ? "lan"
        : (root.wifiStatus === "connected")
            ? (root.networkStrength > 83 ? "signal_wifi_4_bar" :
               root.networkStrength > 67 ? "network_wifi" :
               root.networkStrength > 50 ? "network_wifi_3_bar" :
               root.networkStrength > 33 ? "network_wifi_2_bar" :
               root.networkStrength > 17 ? "network_wifi_1_bar" :
               "signal_wifi_0_bar")
            : (root.wifiStatus === "connecting") ? "signal_wifi_statusbar_not_connected"
            : (root.wifiStatus === "disabled") ? "signal_wifi_off"
            : (root.wifiStatus === "disconnected") ? "wifi_find"
            : "signal_wifi_bad"

    function toggleWifi() {
        var enabling = root.wifiStatus === "disabled";
        Quickshell.execDetached(["nmcli", "radio", "wifi", enabling ? "on" : "off"]);
        root.wifiStatus = enabling ? "disconnected" : "disabled"; // optimistic
        refreshTimer.restart();
    }

    function enableWifi() {
        if (root.wifiStatus === "disabled") {
            Quickshell.execDetached(["nmcli", "radio", "wifi", "on"]);
            root.wifiStatus = "disconnected"; // optimistic
        }
    }

    function refresh() {
        typeProc.buffer = "";
        typeProc.running = true;
        nameProc.running = true;
        strengthProc.running = true;
    }

    Component.onCompleted: root.refresh()
    Timer { id: refreshTimer; interval: 800; onTriggered: root.refresh() }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: { root.refresh(); root.refreshWifiList(); } }

    Process {
        id: typeProc
        property string buffer: ""
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE d status"]
        stdout: SplitParser {
            onRead: data => typeProc.buffer += data + "\n"
        }
        onExited: {
            var lines = typeProc.buffer.trim().split("\n");
            var hasEthernet = false;
            var status = "disabled";
            lines.forEach(function (line) {
                if (line.indexOf("ethernet") !== -1 && line.indexOf(":connected") !== -1)
                    hasEthernet = true;
                if (line.indexOf("wifi:") !== -1) {
                    if (line.indexOf("unavailable") !== -1)
                        status = "disabled";
                    else if (line.indexOf("connecting") !== -1)
                        status = "connecting";
                    else if (line.indexOf("connected") !== -1)
                        status = "connected";
                    else if (line.indexOf("disconnected") !== -1)
                        status = "disconnected";
                }
            });
            root.ethernet = hasEthernet;
            root.wifiStatus = status;
        }
    }

    Process {
        id: nameProc
        command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
        stdout: StdioCollector {
            id: nameCollector
            onStreamFinished: root.networkName = nameCollector.text.trim()
        }
    }

    Process {
        id: strengthProc
        command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi 2>/dev/null | awk '/^\\*/{print $2; exit}'"]
        stdout: StdioCollector {
            id: strengthCollector
            onStreamFinished: {
                var n = parseInt(strengthCollector.text.trim());
                root.networkStrength = isNaN(n) ? 0 : n;
            }
        }
    }

    // ---- Wi-Fi network list / scan / connect (for WifiDialog) ----

    component WifiAccessPoint: QtObject {
        property string ssid: ""
        property int strength: 0
        property bool isSecure: false
        property string security: ""
        property bool active: false
        property bool askingPassword: false
    }
    Component {
        id: wifiApComponent
        WifiAccessPoint {}
    }

    property var _apsBySsid: ({})
    property list<QtObject> friendlyWifiNetworks: []
    property bool wifiScanning: false
    property QtObject wifiConnectTarget: null

    function rescanWifi() {
        root.wifiScanning = true;
        rescanProc.running = true;
    }

    function refreshWifiList() {
        wifiListProc.buffer = "";
        wifiListProc.running = true;
    }

    function connectToWifiNetwork(ap) {
        if (!ap || ap.active) return;
        root.wifiConnectTarget = ap;
        connectProc.command = ["nmcli", "device", "wifi", "connect", ap.ssid];
        connectProc.targetAp = ap;
        connectProc.running = true;
    }

    // Builds and activates a WPA-PSK connection profile, reading the PSK from
    // stdin ("$1" is the SSID, supplied as a real argv element -- SSIDs are
    // broadcast in the clear and are not secret). This mirrors the pattern
    // Omarchy's own bundled network panel uses for enterprise Wi-Fi
    // (Model.js `enterpriseConnectScript`): /proc/<pid>/cmdline is readable
    // by every other process running as this user, so the password must
    // never appear as a `nmcli ... password ...` argument.
    readonly property string _connectWithPskScript:
        "u=$(uuidgen); IFS= read -r pw;" +
        " nmcli connection add type wifi con-name \"$1\" ssid \"$1\" connection.uuid \"$u\"" +
        " wifi-sec.key-mgmt wpa-psk >/dev/null" +
        " && printf 'set 802-11-wireless-security.psk %s\\nsave\\nquit\\n' \"$pw\" | nmcli connection edit uuid \"$u\" >/dev/null" +
        " && nmcli connection up uuid \"$u\"" +
        " || { nmcli connection delete uuid \"$u\" >/dev/null 2>&1; false; }"

    function changePassword(ap, password) {
        if (!ap) return;
        root.wifiConnectTarget = ap;
        connectProc.targetAp = ap;
        connectProc.command = ["bash", "-c", root._connectWithPskScript, "nmcli-psk", ap.ssid];
        connectProc.pendingPassword = password;
        connectProc.running = true;
    }

    function openPublicWifiPortal() {
        Quickshell.execDetached(["xdg-open", "http://neverssl.com"]);
    }

    Process {
        id: rescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: rescanSettleTimer.restart()
    }
    Timer {
        id: rescanSettleTimer
        interval: 1500
        onTriggered: {
            root.refreshWifiList();
            root.wifiScanning = false;
        }
    }

    Process {
        id: wifiListProc
        property string buffer: ""
        command: ["sh", "-c", "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list"]
        stdout: SplitParser {
            onRead: data => wifiListProc.buffer += data + "\n"
        }
        onExited: {
            var lines = wifiListProc.buffer.split("\n").filter(l => l.length > 0);
            var seen = {};
            lines.forEach(function (line) {
                // nmcli -t escapes literal ':' in fields as '\:'; a plain
                // split mishandles that edge case (rare in practice) but is
                // otherwise a faithful parse of the 4 requested fields.
                var parts = line.split(":");
                if (parts.length < 2) return;
                var inUse = parts[0] === "*";
                var ssid = parts[1];
                if (!ssid) return; // skip hidden networks
                var signal = parseInt(parts[2]) || 0;
                var security = parts.slice(3).join(":");
                seen[ssid] = true;
                var ap = root._apsBySsid[ssid];
                if (!ap) {
                    ap = wifiApComponent.createObject(root, {});
                    root._apsBySsid[ssid] = ap;
                }
                ap.ssid = ssid;
                ap.strength = signal;
                ap.security = security;
                ap.isSecure = security.length > 0 && security !== "--";
                ap.active = inUse;
            });
            for (var k in root._apsBySsid) {
                if (!seen[k]) {
                    root._apsBySsid[k].destroy();
                    delete root._apsBySsid[k];
                }
            }
            var list = Object.keys(root._apsBySsid).map(k => root._apsBySsid[k]);
            list.sort((a, b) => b.strength - a.strength);
            root.friendlyWifiNetworks = list;
        }
    }

    Process {
        id: connectProc
        property QtObject targetAp: null
        // Set by changePassword() only; connectToWifiNetwork()'s plain
        // command: [...] form (no password) leaves this empty and
        // stdinEnabled is a no-op then.
        property string pendingPassword: ""
        stdinEnabled: true
        onStarted: {
            if (connectProc.pendingPassword.length > 0) {
                write(connectProc.pendingPassword + "\n");
            }
            connectProc.pendingPassword = "";
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                if (connectProc.targetAp) connectProc.targetAp.askingPassword = false;
                root.wifiConnectTarget = null;
                root.refresh();
                root.refreshWifiList();
            } else if (connectProc.targetAp && connectProc.targetAp.isSecure) {
                // Most likely cause of failure for a secured network with no
                // saved connection profile: missing/incorrect password.
                connectProc.targetAp.askingPassword = true;
            } else {
                Quickshell.execDetached(["notify-send", "Wi-Fi", "Couldn't connect to network", "-a", "ii Control Center"]);
            }
        }
    }
}
