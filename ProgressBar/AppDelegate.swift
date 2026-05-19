import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let taskStore = TaskStore()
    let appSettings = AppSettings()
    private var statusBarController: StatusBarController?
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let settingsWindow = SettingsWindowController(settings: appSettings)
        settingsWindowController = settingsWindow
        let controller = StatusBarController(
            store: taskStore,
            settings: appSettings,
            settingsWindow: settingsWindow
        )
        controller.install()
        statusBarController = controller
    }
}
