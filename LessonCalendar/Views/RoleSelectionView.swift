import SwiftUI

/// 앱 화면 이동 경로
enum AppRoute: Hashable {
    case createLesson                   // 2. 레슨 코드 생성 화면 (대표)
    case joinLesson                     // 4. 수강생 코드 입력 화면
    case home(lessonName: String, lessonCode: String, role: LessonRole)   // 3/5. 캘린더 홈 화면
}

/// 1. 시작 화면 - 역할 선택
struct RoleSelectionView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // 앱 타이틀
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)

                Text("레슨 캘린더")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("레슨 일정을 한눈에 확인하세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 역할 선택 버튼
            VStack(spacing: 16) {
                NavigationLink(value: AppRoute.createLesson) {
                    roleButtonLabel(
                        icon: "plus.circle.fill",
                        title: "레슨 만들기",
                        subtitle: "대표로 레슨방을 만들어요"
                    )
                }
                .buttonStyle(.borderedProminent)

                NavigationLink(value: AppRoute.joinLesson) {
                    roleButtonLabel(
                        icon: "person.badge.key.fill",
                        title: "레슨 참여하기",
                        subtitle: "코드를 입력해서 참여해요"
                    )
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func roleButtonLabel(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .opacity(0.8)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
    }
}

#Preview {
    NavigationStack {
        RoleSelectionView()
    }
}
