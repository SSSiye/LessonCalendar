import WidgetKit
import SwiftUI

struct LessonEntry: TimelineEntry {
    let date: Date
    let hasLesson: Bool
}

struct LessonProvider: TimelineProvider {
    let appGroupID = "group.Siye.LessonCalendar" // ← 변경
    
    func placeholder(in context: Context) -> LessonEntry {
        LessonEntry(date: Date(), hasLesson: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (LessonEntry) -> ()) {
        completion(LessonEntry(date: Date(), hasLesson: todayHasLesson()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LessonEntry>) -> ()) {
        let entry = LessonEntry(date: Date(), hasLesson: todayHasLesson())
        
        // 자정마다 갱신
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
    
    private func todayHasLesson() -> Bool {
        let sharedDefaults = UserDefaults(suiteName: appGroupID)
        let lessonDates = sharedDefaults?.stringArray(forKey: "lessonDates") ?? []
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        return lessonDates.contains(todayString)
    }
}

struct LessonWidgetView: View {
    var entry: LessonEntry
    
    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                Text(dayOfWeekString(from: entry.date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(entry.hasLesson ? .white.opacity(0.8) : .gray)
                
                Text(dayString(from: entry.date))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(entry.hasLesson ? .white : .black)
                
                Text(entry.hasLesson ? "레슨" : "레슨 없음")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(entry.hasLesson ? .white : .gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(entry.hasLesson ? Color.white.opacity(0.3) : Color.clear)
                    .cornerRadius(8)
            }
        }
    }
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func dayOfWeekString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

struct LessonWidget: Widget {
    let kind: String = "LessonWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LessonProvider()) { entry in
            if #available(iOS 17.0, *) {
                LessonWidgetView(entry: entry)
                    .containerBackground(
                        entry.hasLesson ? Color.blue : Color.white,
                        for: .widget
                    )
            } else {
                LessonWidgetView(entry: entry)
                    .background(entry.hasLesson ? Color.blue : Color.white)
            }
        }
        .configurationDisplayName("레슨 확인")
        .description("오늘 레슨 여부를 확인합니다.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    LessonWidget()
} timeline: {
    LessonEntry(date: .now, hasLesson: true)
    LessonEntry(date: .now, hasLesson: false)
}
