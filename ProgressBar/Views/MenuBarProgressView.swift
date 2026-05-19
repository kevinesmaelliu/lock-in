import SwiftUI

struct MenuBarProgressView: View {
    let progress: Double
    let completed: Int
    let total: Int
    let showNumbers: Bool

    private var helpText: String {
        if total == 0 {
            return "No tasks for today"
        }
        return "\(completed) of \(total) done (\(Int((progress * 100).rounded()))%)"
    }

    private var fractionLabel: String {
        "\(completed)/\(total)"
    }

    var body: some View {
        Group {
            if total == 0 {
                emptyState
            } else {
                progressBar
            }
        }
        .frame(width: showNumbers ? 52 : 36, height: 14)
        .accessibilityLabel(helpText)
    }

    @ViewBuilder
    private var emptyState: some View {
        if showNumbers {
            Text("—")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Capsule()
                .fill(Color(nsColor: .tertiaryLabelColor))
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(nsColor: .tertiaryLabelColor))

                if completed > 0 {
                    Capsule()
                        .fill(Color(nsColor: .controlAccentColor))
                        .frame(width: geometry.size.width * CGFloat(progress))
                }

                if showNumbers {
                    Text(fractionLabel)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color(nsColor: .labelColor))
                        .shadow(color: .black.opacity(0.2), radius: 0.5, x: 0, y: 0)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .clipShape(Capsule())
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        MenuBarProgressView(progress: 0, completed: 0, total: 0, showNumbers: true)
        MenuBarProgressView(progress: 0, completed: 0, total: 2, showNumbers: true)
        MenuBarProgressView(progress: 0.4, completed: 2, total: 5, showNumbers: false)
    }
    .padding()
}
