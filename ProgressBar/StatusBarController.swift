import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    private let store: TaskStore
    private let settings: AppSettings
    private let settingsWindow: SettingsWindowController
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var hostingView: NSHostingView<MenuBarProgressView>?
    private var cancellables = Set<AnyCancellable>()

    init(store: TaskStore, settings: AppSettings, settingsWindow: SettingsWindowController) {
        self.store = store
        self.settings = settings
        self.settingsWindow = settingsWindow
        super.init()
    }

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: statusItemLength)
        statusItem = item

        guard let button = item.button else { return }

        let hosting = NSHostingView(rootView: makeProgressView())
        hosting.frame = NSRect(x: 0, y: 0, width: hostingWidth, height: 18)
        hostingView = hosting

        button.subviews.forEach { $0.removeFromSuperview() }
        button.addSubview(hosting)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 4),
            hosting.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -4),
            hosting.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            hosting.heightAnchor.constraint(equalToConstant: 18),
        ])

        button.target = self
        button.action = #selector(togglePopover(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        updateTooltip()

        store.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshLabel()
            }
            .store(in: &cancellables)

        settings.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshLabel()
            }
            .store(in: &cancellables)
    }

    private var statusItemLength: CGFloat {
        settings.showMenuBarNumbers ? 72 : 48
    }

    private var hostingWidth: CGFloat {
        settings.showMenuBarNumbers ? 64 : 40
    }

    private func makeProgressView() -> MenuBarProgressView {
        MenuBarProgressView(
            progress: store.progress,
            completed: store.completedCount,
            total: store.totalCount,
            showNumbers: settings.showMenuBarNumbers
        )
    }

    private func refreshLabel() {
        statusItem?.length = statusItemLength
        hostingView?.frame.size.width = hostingWidth
        hostingView?.rootView = makeProgressView()
        updateTooltip()
    }

    private func updateTooltip() {
        let total = store.totalCount
        let completed = store.completedCount
        if total == 0 {
            statusItem?.button?.toolTip = "Progress Bar — no tasks for today"
        } else {
            let percent = Int((store.progress * 100).rounded())
            statusItem?.button?.toolTip = "\(completed) of \(total) done (\(percent)%)"
        }
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button else { return }

        if popover?.isShown == true {
            popover?.performClose(sender)
            return
        }

        let popover = self.popover ?? makePopover()
        self.popover = popover
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func makePopover() -> NSPopover {
        let popover = NSPopover()
        popover.behavior = .applicationDefined
        popover.contentSize = NSSize(width: 300, height: 360)
        popover.contentViewController = NSHostingController(
            rootView: MenuContentView(onOpenSettings: { [settingsWindow] in
                settingsWindow.show()
            })
            .environmentObject(store)
            .environmentObject(settings)
        )
        return popover
    }
}
