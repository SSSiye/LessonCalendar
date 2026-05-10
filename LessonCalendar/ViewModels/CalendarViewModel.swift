// MARK: - CalendarViewModel.swift

import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var month: Date
    @Published var clickedDates: Set<Date> = []
    
    init(month: Date) {
        self.month = month
    }
    
    // MARK: - 날짜 관련 계산 프로퍼티
    
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
    
    // MARK: - 메서드
    
    func getDate(for day: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day, to: startOfMonth())!
    }
    
    func toggleDate(_ date: Date) {
        if clickedDates.contains(date) {
            clickedDates.remove(date)
        } else {
            clickedDates.insert(date)
        }
    }
    
    func isClicked(_ date: Date) -> Bool {
        clickedDates.contains(date)
    }
    
    func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: month) {
            month = newMonth
        }
    }
    
    // MARK: - Private
    
    private func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        return Calendar.current.date(from: components)!
    }
    
    // MARK: - Static
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
}
