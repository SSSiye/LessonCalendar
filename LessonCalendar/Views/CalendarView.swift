// MARK: - CalendarView.swift

import SwiftUI

struct CalendarView: View {
    @StateObject private var vm = CalendarViewModel(month: Date())
    
    var body: some View {
        VStack {
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
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(0 ..< vm.daysInMonth + vm.firstWeekday, id: \.self) { index in
                if index < vm.firstWeekday {
                    Color.clear
                        .aspectRatio(1, contentMode: .fit) // 빈 칸 비율 유지
                } else {
                    let date = vm.getDate(for: index - vm.firstWeekday)
                    let day = index - vm.firstWeekday + 1
                    
                    CellView(day: day, clicked: vm.isClicked(date))
                        .onTapGesture {
                            vm.toggleDate(date)
                        }
                }
            }
        }
    }
}

// MARK: - CellView.swift

private struct CellView: View {
    let day: Int
    let clicked: Bool
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 5)
                .opacity(0)
                .overlay(Text(String(day)))
                .foregroundColor(.blue)
            
            if clicked {
                Text("Click")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
}
