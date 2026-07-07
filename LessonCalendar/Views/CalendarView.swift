import SwiftUI
import WidgetKit

struct CalendarView: View {
    @StateObject private var vm: CalendarViewModel
    @State private var isEditing: Bool = false
    @State private var currentOffset: Int = 0

    init(lessonCode: String? = nil) {
        _vm = StateObject(wrappedValue: CalendarViewModel(month: Date(), lessonCode: lessonCode))
    }

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
        .task {
            await vm.loadFromFirestore()
        }
        .alert("오류", isPresented: .init(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private var headerView: some View {
        HStack {
            Spacer()
            Text(vm.monthTitle)
                .font(.title)
            Spacer()
            if vm.isSaving {
                ProgressView()
                    .padding(.trailing)
            } else {
                Button(isEditing ? "저장" : "수정") {
                    isEditing.toggle()
                    // 수정을 마치면 수강생들이 볼 수 있도록 Firestore에 저장
                    if !isEditing {
                        Task {
                            await vm.saveToFirestore()
                        }
                    }
                }
                .foregroundColor(.blue)
                .padding(.trailing)
            }
        }
        .padding(.vertical, 12)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(CalendarViewModel.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
    }

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
                clicked: vm.isClicked(date),
                isToday: Calendar.current.isDateInToday(date)
            )
            .onTapGesture {
                if isEditing {
                    vm.toggleDate(date)
                }
            }
        }
    }

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
}

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
}
