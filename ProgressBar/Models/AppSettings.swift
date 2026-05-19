import Foundation

final class AppSettings: ObservableObject {
    private static let showMenuBarNumbersKey = "showMenuBarNumbers"

    @Published var showMenuBarNumbers: Bool {
        didSet {
            UserDefaults.standard.set(showMenuBarNumbers, forKey: Self.showMenuBarNumbersKey)
        }
    }

    init() {
        if UserDefaults.standard.object(forKey: Self.showMenuBarNumbersKey) == nil {
            showMenuBarNumbers = true
        } else {
            showMenuBarNumbers = UserDefaults.standard.bool(forKey: Self.showMenuBarNumbersKey)
        }
    }
}
