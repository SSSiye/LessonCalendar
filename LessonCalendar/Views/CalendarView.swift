import SwiftUI
import SwiftData

struct CalendarView: View {
    @StateObject private var vm = CalendarViewModel(month: Date())
    @Query private var clickedDates: [ClickedDate]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            headerView
            calendarGridView
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width < -100 {
                        vm.changeMonth(by: 1)
                    } else if gesture.translation.width > 100 {
                        vm.changeMonth(by: -1)
                    }
                }
        )
    }

    // MARK: - 헤더 뷰
    private var headerView: some View {
        VStack {
            Text(vm.monthTitle)
                .font(.title)
                .padding(.bottom)

            HStack {
                ForEach(CalendarViewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 5)
        }
    }

    // MARK: - 날짜 그리드 뷰
    private var calendarGridView: some View {
        let totalCells = vm.daysInMonth + vm.firstWeekday
        let totalRows = Int(ceil(Double(totalCells) / 7.0))

        return LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0) {
            ForEach(0 ..< totalRows * 7, id: \.self) { index in
                cellView(for: index, totalCells: totalCells)
            }
        }
    }

    @ViewBuilder
    private func cellView(for index: Int, totalCells: Int) -> some View {
        if index < vm.firstWeekday || index >= totalCells {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: 80)
                .border(Color.gray.opacity(0.3), width: 0.5)
        } else {
            let date = vm.getDate(for: index - vm.firstWeekday)
            let day = index - vm.firstWeekday + 1

            CellView(
                day: day,
                clicked: isClicked(date),
                isToday: Calendar.current.isDateInToday(date)
            )
            .onTapGesture {
                toggleDate(date)
            }
        }
    }

    // MARK: - 메서드
    private func isClicked(_ date: Date) -> Bool {
        clickedDates.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private func toggleDate(_ date: Date) {
        if let existing = clickedDates.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(ClickedDate(date: date))
        }
    }
}

// MARK: - CellView
private struct CellView: View {
    let day: Int
    let clicked: Bool
    let isToday: Bool

    var body: some View {
        ZStack {
            if isToday {
                Circle()
                    .stroke(clicked ? Color.white : Color.blue, lineWidth: 1.5)
                    .padding(4)
            }

            Text(String(day))
                .font(.system(size: 14))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(clicked ? Color.blue : Color.clear)
        .border(Color.gray.opacity(0.3), width: 0.5)
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: ClickedDate.self, inMemory: true)
}
