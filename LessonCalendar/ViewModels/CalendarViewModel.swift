import SwiftUI
import WidgetKit

class CalendarViewModel: ObservableObject {
    @Published var month: Date
    @Published var clickedDates: Set<Date> = []

    init(month: Date) {
        self.month = month
        loadFromUserDefaults()
    }

    func month(for offset: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: offset, to: Date()) ?? Date()
    }

    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 0
    }

    var firstWeekday: Int {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
    }

    var monthTitle: String {
        Self.dateFormatter.string(from: month)
    }

    func getDate(for day: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day, to: startOfMonth())!
    }

    func toggleDate(_ date: Date) {
        // 날짜 비교를 일(day) 기준으로
        if let existing = clickedDates.first(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            clickedDates.remove(existing)
        } else {
            clickedDates.insert(date)
        }
        syncToWidget()
    }

    func isClicked(_ date: Date) -> Bool {
        clickedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }

    func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: month) {
            month = newMonth
        }
    }

    // MARK: - UserDefaults 저장/불러오기

    func syncToWidget() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStrings = clickedDates.map { formatter.string(from: $0) }

        let sharedDefaults = UserDefaults(suiteName: "group.Siye.LessonCalendar")
        sharedDefaults?.set(dateStrings, forKey: "lessonDates")

        print("💛 저장된 날짜들: \(dateStrings)")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func loadFromUserDefaults() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let sharedDefaults = UserDefaults(suiteName: "group.Siye.LessonCalendar")
        let dateStrings = sharedDefaults?.stringArray(forKey: "lessonDates") ?? []

        clickedDates = Set(dateStrings.compactMap { formatter.date(from: $0) })
        print("💛 불러온 날짜들: \(dateStrings)")
    }

    // MARK: - Private

    private func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        return Calendar.current.date(from: components)!
    }

    // MARK: - Static

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()

    static let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
}
