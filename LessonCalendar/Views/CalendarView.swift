import SwiftUI
import SwiftData

struct CalendarView: View {
    @StateObject private var vm = CalendarViewModel(month: Date())
    @Query private var clickedDates: [ClickedDate]
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing: Bool = false
    @State private var currentOffset: Int = 0  // ← 현재 월 오프셋

    var body: some View {
        VStack(spacing: 0) {
            headerView
            weekdayHeader
            
            TabView(selection: $currentOffset) {
                ForEach(-12 ..< 12, id: \.self) { offset in
                    monthGridView(for: vm.month(for: offset))
                        .tag(offset)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)  
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentOffset) { _, newOffset in
                vm.month = vm.month(for: newOffset)
            }
        }
    }

    // MARK: - 헤더
    private var headerView: some View {
        HStack {
            Spacer()
            Text(vm.monthTitle)
                .font(.title)
            Spacer()
            Button(isEditing ? "완료" : "수정") {
                isEditing.toggle()
            }
            .foregroundColor(.blue)
            .padding(.trailing)
        }
        .padding(.vertical, 12)  // 위아래 패딩만
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(CalendarViewModel.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))  // 살짝 구분선 느낌
    }

    // MARK: - 월별 그리드
    private func monthGridView(for month: Date) -> some View {
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 0
        let firstWeekday = firstWeekdayOf(month: month)
        let totalCells = daysInMonth + firstWeekday
        let totalRows = Int(ceil(Double(totalCells) / 7.0))

        return LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0) {
            ForEach(0 ..< totalRows * 7, id: \.self) { index in
                cellView(for: index, totalCells: totalCells, firstWeekday: firstWeekday, month: month)
            }
        }
    }

    @ViewBuilder
    private func cellView(for index: Int, totalCells: Int, firstWeekday: Int, month: Date) -> some View {
        if index < firstWeekday || index >= totalCells {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: 80)
                .border(Color.gray.opacity(0.3), width: 0.5)
        } else {
            let date = getDate(for: index - firstWeekday, in: month)
            let day = index - firstWeekday + 1

            CellView(
                day: day,
                clicked: isClicked(date),
                isToday: Calendar.current.isDateInToday(date)
            )
            .onTapGesture {
                if isEditing {
                    toggleDate(date)
                }
            }
        }
    }

    // MARK: - 헬퍼
    private func firstWeekdayOf(month: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        let firstDay = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: firstDay) - 1
    }

    private func getDate(for day: Int, in month: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        let startOfMonth = Calendar.current.date(from: components)!
        return Calendar.current.date(byAdding: .day, value: day, to: startOfMonth)!
    }

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
