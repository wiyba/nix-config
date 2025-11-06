import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    signal authenticationSucceeded()
    signal authenticationFailed(reason: string)
    signal verifying()

    property bool active: false
    property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/ii/modules/lock/scripts/fprintd_auth.py"

    property var authProc: Process {
        running: false
        command: ["python", root.scriptPath]

        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("FPAUTH:")) {
                    var parts = data.substring(7).split(":");
                    var status = parts[0];

                    if (status === "SUCCESS") {
                        root.authenticationSucceeded();
                    } else if (status === "FAILED") {
                        var reason = parts.length > 1 ? parts[1] : "Unknown error";
                        root.authenticationFailed(reason);
                    } else if (status === "VERIFY_STARTED") {
                        root.verifying();
                    } else if (status === "ERROR") {
                        var error = parts.length > 1 ? parts.slice(1).join(":") : "Unknown error";
                        root.authenticationFailed(error);
                    } else if (status === "TIMEOUT") {
                        root.authenticationFailed("Timeout");
                    }
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                if (!data.includes("dbus.connection") && !data.includes("SystemExit")) {
                    console.error("Fingerprint error:", data);
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.active = false;
            if (exitCode !== 0 && exitCode !== 1) {
                root.authenticationFailed("Process exited unexpectedly");
            }
        }
    }

    function start() {
        if (root.active) return;

        root.active = true;
        authProc.running = true;
    }

    function stop() {
        if (!root.active) return;

        root.active = false;
        authProc.running = false;
    }

    Component.onDestruction: {
        if (root.active) root.stop();
    }
}
