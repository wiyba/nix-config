#!/usr/bin/env python3
import sys
import os
import signal
from gi.repository import GLib
import dbus
import dbus.mainloop.glib

def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()

    username = os.getenv('USER')
    print(f"FPAUTH:USERNAME:{username}", flush=True)

    device_path = "/net/reactivated/Fprint/Device/0"
    try:
        device = bus.get_object('net.reactivated.Fprint', device_path)
        device_iface = dbus.Interface(device, 'net.reactivated.Fprint.Device')
    except Exception as e:
        print(f"FPAUTH:ERROR:Failed to get device: {e}", flush=True)
        return 1

    print("FPAUTH:CLAIMING", flush=True)
    try:
        device_iface.Claim(username)
        print("FPAUTH:CLAIMED", flush=True)
    except Exception as e:
        print(f"FPAUTH:ERROR:Failed to claim: {e}", flush=True)
        return 1
    def verify_status(result, done):
        print(f"FPAUTH:VERIFY_STATUS:{result}:{done}", flush=True)
        if result == "verify-match" and done:
            print("FPAUTH:SUCCESS", flush=True)
            cleanup_and_exit(0)
        elif result in ["verify-no-match", "verify-disconnected", "verify-unknown-error"]:
            if done:
                print(f"FPAUTH:FAILED:{result}", flush=True)
                cleanup_and_exit(1)

    def cleanup_and_exit(code):
        try:
            device_iface.VerifyStop()
        except:
            pass
        try:
            device_iface.Release()
            print("FPAUTH:RELEASED", flush=True)
        except:
            pass
        loop.quit()
        GLib.timeout_add(100, lambda: sys.exit(code))

    device.connect_to_signal("VerifyStatus", verify_status,
                             dbus_interface='net.reactivated.Fprint.Device')

    print("FPAUTH:STARTING_VERIFY", flush=True)
    try:
        device_iface.VerifyStart("any")
        print("FPAUTH:VERIFY_STARTED", flush=True)
    except Exception as e:
        print(f"FPAUTH:ERROR:Failed to start verify: {e}", flush=True)
        cleanup_and_exit(1)

    loop = GLib.MainLoop()

    def signal_handler(signum, frame):
        print("FPAUTH:TERMINATED", flush=True)
        cleanup_and_exit(1)

    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    def timeout():
        print("FPAUTH:TIMEOUT", flush=True)
        cleanup_and_exit(1)

    GLib.timeout_add_seconds(30, timeout)

    try:
        loop.run()
    except KeyboardInterrupt:
        print("FPAUTH:INTERRUPTED", flush=True)
        cleanup_and_exit(1)

    return 0

if __name__ == "__main__":
    sys.exit(main())
