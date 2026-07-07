import SwiftUI

struct ContentView: View {
    /// 저장된 세션이 있으면 역할 선택 없이 바로 탭 화면으로 진입
    @State private var session: LessonSession? = LessonSession.load()

    var body: some View {
        if let session {
            MainTabView(session: session) {
                // 레슨방 삭제/나가기 시 다시 역할 선택 화면부터 시작
                self.session = nil
            }
        } else {
            NavigationStack {
                RoleSelectionView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .createLesson:
                            CreateLessonView { session = $0 }
                        case .joinLesson:
                            JoinLessonView { session = $0 }
                        }
                    }
            }
        }
    }
}

/// 하단 탭 - 캘린더 / 설정
struct MainTabView: View {
    let session: LessonSession
    /// 레슨방 삭제/나가기 후 역할 선택 화면으로 돌아가기 위한 콜백
    let onLeave: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                CalendarView(lessonCode: session.lessonCode, isEditable: session.role == .owner)
                    .navigationTitle(session.lessonName)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("캘린더", systemImage: "calendar")
            }

            NavigationStack {
                SettingsView(session: session, onLeave: onLeave)
            }
            .tabItem {
                Label("설정", systemImage: "gearshape")
            }
        }
    }
}

#Preview {
    ContentView()
}
