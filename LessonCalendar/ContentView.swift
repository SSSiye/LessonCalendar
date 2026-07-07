import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            RoleSelectionView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .createLesson:
                        // TODO: 2. 레슨 코드 생성 화면으로 교체
                        Text("레슨 코드 생성 화면 (준비 중)")
                    case .joinLesson:
                        // TODO: 4. 수강생 코드 입력 화면으로 교체
                        Text("레슨 코드 입력 화면 (준비 중)")
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
