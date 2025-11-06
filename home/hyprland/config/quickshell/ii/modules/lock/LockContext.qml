import qs
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    enum ActionEnum { Unlock, Poweroff, Reboot }

    signal shouldReFocus()
    signal unlocked(targetAction: var)
    signal failed()

    // These properties are in the context and not individual lock surfaces
    // so all surfaces can share the same state.
    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property var targetAction: LockContext.ActionEnum.Unlock
    property string fingerprintStatus: ""

    function resetTargetAction() {
        root.targetAction = LockContext.ActionEnum.Unlock;
    }

    function clearText() {
        root.currentText = "";
    }

    function resetClearTimer() {
        passwordClearTimer.restart();
    }

    function reset() {
        root.resetTargetAction();
        root.clearText();
        root.unlockInProgress = false;
        root.fingerprintStatus = "";
        root.stopFingerprint();
    }

    Timer {
        id: passwordClearTimer
        interval: 10000
        onTriggered: {
            root.reset();
        }
    }

    onCurrentTextChanged: {
        if (currentText.length > 0) {
            showFailure = false;
            GlobalStates.screenUnlockFailed = false;
        }
        GlobalStates.screenLockContainsCharacters = currentText.length > 0;
        passwordClearTimer.restart();
    }

    function tryUnlock() {
        root.unlockInProgress = true;
        fingerprint.stop();
        fingerprintRestartTimer.stop();
        pam.start();
    }

    PamContext {
        id: pam
        config: "quickshell-lock"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText);
            }
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                fingerprint.stop();
                fingerprintRestartTimer.stop();
                root.unlocked(root.targetAction);
            } else {
                root.clearText();
                root.unlockInProgress = false;
                GlobalStates.screenUnlockFailed = true;
                root.showFailure = true;
                fingerprint.start();
            }
        }
    }

    FingerprintAuth {
        id: fingerprint

        onAuthenticationSucceeded: {
            root.fingerprintStatus = "Fingerprint matched!";
            root.unlocked(root.targetAction);
        }

        onAuthenticationFailed: reason => {
            root.fingerprintStatus = "Fingerprint: " + reason;
            if (GlobalStates.screenLocked) {
                fingerprintRestartTimer.start();
            }
        }

        onVerifying: {
            root.fingerprintStatus = "Place your finger...";
        }
    }

    Timer {
        id: fingerprintRestartTimer
        interval: 1000
        repeat: false
        onTriggered: fingerprint.start()
    }

    function startFingerprint() {
        root.showFailure = false;
        GlobalStates.screenUnlockFailed = false;
        root.fingerprintStatus = "Place your finger...";
        fingerprint.start();
    }

    function stopFingerprint() {
        fingerprint.stop();
        fingerprintRestartTimer.stop();
    }

}
