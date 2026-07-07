import SwiftUI
import WidgetKit

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var month: Date
    @Published var clickedDates: Set<Date> = []
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    /// 참여 중인 레슨방 코드 - 있으면 Firestore와 동기화
    let lessonCode: String?

    init(month: Date, lessonCode: String? = nil) {
        self.month = month
        self.lessonCode = lessonCode
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

    // MARK: - Firestore 동기화

    /// Firestore에서 레슨 날짜를 불러와 화면과 위젯에 반영
    func loadFromFirestore() async {
        guard let lessonCode else { return }

        do {
            let dateStrings = try await FirestoreService.shared.fetchLessonDates(code: lessonCode)
            clickedDates = Set(dateStrings.compactMap { Self.dayFormatter.date(from: $0) })
            syncToWidget()
        } catch {
            errorMessage = "레슨 날짜를 불러오지 못했어요: \(error.localizedDescription)"
        }
    }

    /// 현재 선택된 날짜들을 Firestore에 저장 (수강생들이 볼 수 있게)
    func saveToFirestore() async {
        guard let lessonCode else { return }

        isSaving = true
        let dateStrings = clickedDates.map { Self.dayFormatter.string(from: $0) }.sorted()

        do {
            try await FirestoreService.shared.updateLessonDates(code: lessonCode, dates: dateStrings)
        } catch {
            errorMessage = "레슨 날짜 저장에 실패했어요: \(error.localizedDescription)"
        }
        isSaving = false
    }

    // MARK: - UserDefaults 저장/불러오기

    func syncToWidget() {
        let dateStrings = clickedDates.map { Self.dayFormatter.string(from: $0) }

        let sharedDefaults = UserDefaults(suiteName: "group.Siye.LessonCalendar")
        sharedDefaults?.set(dateStrings, forKey: "lessonDates")

        print("💛 저장된 날짜들: \(dateStrings)")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func loadFromUserDefaults() {
        let sharedDefaults = UserDefaults(suiteName: "group.Siye.LessonCalendar")
        let dateStrings = sharedDefaults?.stringArray(forKey: "lessonDates") ?? []

        clickedDates = Set(dateStrings.compactMap { Self.dayFormatter.date(from: $0) })
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

    /// Firestore와 위젯 공유에 함께 쓰는 날짜 포맷
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
}
