import Foundation

final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [DailyTask] = []

    private static let storageKey = "com.progressbar.daily.tasks"
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = Calendar.current.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var totalCount: Int {
        tasks.count
    }

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var progressPercent: Int {
        Int((progress * 100).rounded())
    }

    init() {
        load()
    }

    func addTask(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.append(DailyTask(title: trimmed))
        save()
    }

    func toggleTask(_ task: DailyTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        save()
    }

    func deleteTask(_ task: DailyTask) {
        tasks.removeAll { $0.id == task.id }
        save()
    }

    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        save()
    }

    func clearCompleted() {
        tasks.removeAll(where: \.isCompleted)
        save()
    }

    private func todayKey() -> String {
        dayFormatter.string(from: Date())
    }

    private func load() {
        let today = todayKey()

        guard
            let data = UserDefaults.standard.data(forKey: Self.storageKey),
            let saved = try? JSONDecoder().decode(DayTasks.self, from: data)
        else {
            tasks = []
            return
        }

        if saved.dayKey == today {
            tasks = saved.tasks
        } else {
            tasks = []
            save()
        }
    }

    private func save() {
        let payload = DayTasks(dayKey: todayKey(), tasks: tasks)
        guard let data = try? JSONEncoder().encode(payload) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
