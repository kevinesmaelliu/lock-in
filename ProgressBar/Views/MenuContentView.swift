import AppKit
import SwiftUI

struct MenuContentView: View {
    let onOpenSettings: () -> Void

    @EnvironmentObject private var store: TaskStore
    @EnvironmentObject private var settings: AppSettings
    @State private var newTaskTitle = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            taskList
            Divider()
            addTaskField
            footer
        }
        .frame(width: 300)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.headline)

            HStack(spacing: 10) {
                ProgressView(value: store.progress)
                    .progressViewStyle(.linear)

                Text(store.totalCount == 0 ? "—" : "\(store.completedCount)/\(store.totalCount)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 28, alignment: .trailing)
            }

            if store.totalCount > 0 {
                Text("\(store.progressPercent)% complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Add tasks to track your day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
    }

    private var taskList: some View {
        Group {
            if store.tasks.isEmpty {
                Text("No tasks yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 72, alignment: .center)
            } else {
                List {
                    ForEach(store.tasks) { task in
                        TaskRowView(task: task) {
                            store.toggleTask(task)
                        }
                    }
                    .onDelete { offsets in
                        store.deleteTasks(at: offsets)
                    }
                }
                .listStyle(.plain)
                .frame(minHeight: 120, maxHeight: 240)
            }
        }
    }

    private var addTaskField: some View {
        HStack(spacing: 8) {
            TextField("New task…", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .onSubmit(addTask)

            Button("Add", action: addTask)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(12)
    }

    private var footer: some View {
        VStack(spacing: 8) {
            HStack {
                Button("Clear completed") {
                    store.clearCompleted()
                }
                .disabled(store.completedCount == 0)

                Spacer()

                Button(action: onOpenSettings) {
                    Image(systemName: "gear")
                        .font(.system(size: 12))
                }
                .help("Settings")

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }

            Link(destination: AppLinks.lockIn) {
                HStack(spacing: 3) {
                    Text("Lock In")
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 9, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .font(.caption)
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
    }

    private func addTask() {
        store.addTask(title: newTaskTitle)
        newTaskTitle = ""
        isInputFocused = true
    }

}

#Preview {
    MenuContentView(onOpenSettings: {})
        .environmentObject(TaskStore())
        .environmentObject(AppSettings())
}
