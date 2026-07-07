import SwiftUI

struct ContentView: View {
    /// 저장된 세션이 있으면 역할 선택 없이 바로 캘린더로 진입
    @State private var session: LessonSession? = LessonSession.load()

    var body: some View {
        NavigationStack {
            if let session {
                CalendarView(lessonCode: session.lessonCode, isEditable: session.role == .owner)
                    .navigationTitle(session.lessonName)
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                RoleSelectionView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .createLesson:
                            CreateLessonView()
                        case .joinLesson:
                            JoinLessonView()
                        case .home(let lessonName, let lessonCode, let role):
                            CalendarView(lessonCode: lessonCode, isEditable: role == .owner)
                                .navigationTitle(lessonName)
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationBarBackButtonHidden(true)
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
