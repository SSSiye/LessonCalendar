import SwiftUI

struct ContentView: View {
    /// 저장된 세션이 있으면 역할 선택 없이 바로 캘린더로 진입
    @State private var session: LessonSession? = LessonSession.load()

    var body: some View {
        NavigationStack {
            if let session {
                CalendarView(lessonCode: session.lessonCode)
                    .navigationTitle(session.lessonName)
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                RoleSelectionView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .createLesson:
                            CreateLessonView()
                        case .joinLesson:
                            // TODO: 4. 수강생 코드 입력 화면으로 교체
                            Text("레슨 코드 입력 화면 (준비 중)")
                        case .home(let lessonName, let lessonCode):
                            CalendarView(lessonCode: lessonCode)
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
