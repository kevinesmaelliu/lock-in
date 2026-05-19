import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private let settings: AppSettings
    private var window: NSWindow?

    private let windowSize = NSSize(width: 400, height: 136)

    init(settings: AppSettings) {
        self.settings = settings
        super.init()
    }

    func show() {
        if window == nil {
            let hosting = NSHostingController(
                rootView: SettingsView()
                    .environmentObject(settings)
            )
            hosting.view.frame = NSRect(origin: .zero, size: windowSize)

            let window = NSWindow(
                contentRect: NSRect(origin: .zero, size: windowSize),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Settings"
            window.contentViewController = hosting
            window.contentMinSize = windowSize
            window.contentMaxSize = windowSize
            window.isReleasedWhenClosed = false
            window.delegate = self
            self.window = window
        }

        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        window?.orderOut(nil)
    }
}
