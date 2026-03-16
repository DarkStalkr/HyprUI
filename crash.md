Post-Mortem: Quickshell UI Segmentation Fault
Executive Summary

The Quickshell UI was experiencing abrupt, silent crashes that circumvented standard application logging. Investigation via system logs and core dumps identified the root cause as a Segmentation Fault (SIGSEGV) triggered by a null pointer dereference within the Qt 6 QML engine. The crash was caused by unbound QML Timer components attempting to modify properties of UI and Process objects that had already been destroyed or garbage-collected. Implementing defensive JavaScript type-checking within the timer callbacks resolved the instability.
1. Discoveries: The Investigation
1.1 Initial Log Analysis

The application logs (log.qslog and log.log) showed standard background operations (such as successfully polling the open-meteo API) but ended abruptly without recording any fatal exceptions, Wayland disconnects, or Qt critical warnings. This indicated a sudden process termination by the OS kernel, pointing toward either an Out-Of-Memory (OOM) kill or a lower-level memory violation.
1.2 System-Level Logs

Querying journalctl and coredumpctl confirmed the application was killed due to a segmentation fault:
Plaintext

mar 15 00:30:08 archlinux kernel: quickshell[1847]: segfault at 177 ip 00007f9a8d0c6884 sp 00007fff4474bd28 error 4 in libQt6Qml.so.6.10.2
mar 15 00:30:08 archlinux systemd-coredump[113988]: Process 1847 (quickshell) ... terminated abnormally with signal 11/SEGV

The memory address 177 (near 0x0) strongly indicated a null pointer dereference occurring natively inside the libQt6Qml.so library.
1.3 Core Dump Backtrace

Analyzing the core dump via GDB revealed the exact execution chain leading to the crash:

    Frame #22 (QQmlTimer::event): The event loop fired a QML Timer component.

    Frames #18-16 (QQmlBoundSignalExpression::evaluate): The timer executed its bound onTriggered JavaScript signal.

    Frames #7-3 (QV4::QObjectWrapper::setQmlProperty): The JavaScript engine attempted to assign a value to a QObject property.

    Frames #1-0: The engine attempted to access the heap data for the object, found it invalid/null, and triggered the SIGSEGV.

2. Hypothesis: Root Cause Analysis

Based on the backtrace, we hypothesized that a QML Timer outlived its target object.

When QML components are created dynamically (e.g., UI panels assigned to physical screens via Variants { model: Quickshell.screens }), they are destroyed when the underlying model changes (e.g., a monitor goes to sleep or disconnects). Similarly, internal C++ process wrappers can be garbage-collected.

If a Timer is left running when its parent or target object is destroyed, the Qt Event Loop may still execute the timer's onTriggered block. When the JavaScript engine attempts a property assignment (e.g., root.active = false or myProcess.running = true) on a destroyed object, the C++ backend tries to access a freed memory pointer, resulting in a fatal segmentation fault.
3. Proposed Solutions: Implementation

To fix this, we must enforce memory safety at the QML/JS boundary. We implemented a defensive programming pattern inside the onTriggered blocks of all risky timers to verify object existence before property assignment.

The Safety Check Pattern:
JavaScript

if (typeof targetObject !== "undefined" && targetObject !== null) {
    targetObject.property = value;
}

3.1 Resolving UI Panel Crashes (MediaPanel.qml & HyprOSD.qml)

These panels are dynamically created per screen. Their hide/show timers must be guarded against screen disconnections.

Fix applied to HyprOSD.qml (and similarly to MediaPanel.qml):
QML

Timer {
    id: hideTimer
    interval: 1800
    onTriggered: {
        // Prevent crash if the OSD was destroyed by screen disconnect
        if (typeof root !== "undefined" && root !== null) {
            root.active = false;
        }
    }
}

3.2 Resolving Background Process Crashes (SystemUsage.qml)

The system usage dashboard aggressively polls multiple system resources using external processes. The polling timer must ensure the process wrappers are still valid in memory.

Fix applied to SystemUsage.qml:
QML

Timer {
    running: root.refCount > 0
    interval: Config.dashboard.resourceUpdateInterval
    repeat: true
    onTriggered: {
        // Prevent crash if QML garbage collection removes process wrappers
        if (typeof stat !== "undefined" && stat !== null) stat.reload();
        if (typeof meminfo !== "undefined" && meminfo !== null) meminfo.reload();
        if (typeof storage !== "undefined" && storage !== null) storage.running = true;
        if (typeof gpuUsage !== "undefined" && gpuUsage !== null) gpuUsage.running = true;
        if (typeof sensors !== "undefined" && sensors !== null) sensors.running = true;
    }
}

4. Next Steps & Recommendations

While the immediate crash vectors have been patched, the codebase contains other dynamic components that utilize polling or delayed execution.

    Audit Network Manager (Nmcli.qml): The connectionCheckTimer and immediateCheckTimer interact heavily with active processes and command wrappers. These should be reviewed and updated with the exact same typeof safety pattern.

    Audit Notification Daemons (NotificationPopups.qml): The displayTimer and nextTimer should be guarded, as notifications are highly ephemeral objects.

    Future Development: Adopt a standard practice of validating object references inside all asynchronous callbacks, Promises, and Timers within the QML environment to ensure long-term shell stability.
