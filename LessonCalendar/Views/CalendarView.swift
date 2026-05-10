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
        let totalCells = vm.daysInMonth + vm.firstWeekday
        let totalRows = Int(ceil(Double(totalCells) / 7.0))
        
        return LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0) {
            ForEach(0 ..< totalRows * 7, id: \.self) { index in
                if index < vm.firstWeekday || index >= totalCells {
                    Color.clear
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .border(Color.gray.opacity(0.3), width: 0.5)
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
        VStack(spacing: 4) {
            Text(String(day))
                .font(.system(size: 14))
                .foregroundColor(clicked ? .white : .primary)
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(clicked ? Color.blue : Color.clear)
//            
//            if clicked {
//                Text("Click")
//                    .font(.caption)
//                    .foregroundColor(.red)
//            }
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .border(Color.gray.opacity(0.3), width: 0.5) // ← 셀 테두리
    }
}


// MARK: - Preview

#Preview {
    CalendarView()
}
