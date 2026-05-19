import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Show count in menu bar", isOn: $settings.showMenuBarNumbers)
                .toggleStyle(.switch)
        }
        .padding(24)
        .frame(width: 360, height: 88, alignment: .topLeading)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
