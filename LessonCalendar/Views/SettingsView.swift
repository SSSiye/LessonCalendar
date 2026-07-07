import SwiftUI
import WidgetKit

/// 6. 설정 화면 - 대표는 코드 확인/공유/레슨방 삭제, 수강생은 레슨 확인/나가기
struct SettingsView: View {
    let session: LessonSession
    /// 레슨방 삭제/나가기 후 역할 선택 화면으로 돌아가기 위한 콜백
    let onLeave: () -> Void

    @State private var isDeleting: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var showLeaveConfirm: Bool = false
    @State private var errorMessage: String = ""

    /// 공유 시트로 보낼 초대 메시지
    private var shareMessage: String {
        """
        『\(session.lessonName)』 레슨에 초대해요! 🏸
        레슨 캘린더 앱에서 아래 코드를 입력하면 일정을 확인할 수 있어요.

        레슨 코드: \(session.lessonCode)
        """
    }

    var body: some View {
        List {
            Section("참여 중인 레슨") {
                LabeledContent("레슨 이름", value: session.lessonName)

                if session.role == .owner {
                    LabeledContent("레슨 코드") {
                        Text(session.lessonCode)
                            .font(.body.monospaced())
                            .fontWeight(.semibold)
                    }
                }
            }

            if session.role == .owner {
                Section {
                    ShareLink(item: shareMessage) {
                        Label("수강생에게 코드 공유하기", systemImage: "square.and.arrow.up")
                    }
                } footer: {
                    Text("수강생이 이 코드를 입력하면 레슨 일정을 볼 수 있어요.")
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        if isDeleting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Label("레슨방 삭제", systemImage: "trash")
                        }
                    }
                    .disabled(isDeleting)
                } footer: {
                    Text("레슨방을 삭제하면 수강생들도 더 이상 일정을 볼 수 없어요.")
                }
            } else {
                Section {
                    Button(role: .destructive) {
                        showLeaveConfirm = true
                    } label: {
                        Label("레슨 나가기", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } footer: {
                    Text("나간 후에도 코드를 다시 입력하면 참여할 수 있어요.")
                }
            }

            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .alert("레슨방을 삭제할까요?", isPresented: $showDeleteConfirm) {
            Button("삭제", role: .destructive) {
                deleteLesson()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제하면 되돌릴 수 없고, 수강생들도 일정을 볼 수 없어요.")
        }
        .alert("레슨에서 나갈까요?", isPresented: $showLeaveConfirm) {
            Button("나가기", role: .destructive) {
                leaveLesson()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("나간 후에도 코드를 다시 입력하면 참여할 수 있어요.")
        }
    }

    /// 대표: Firestore의 레슨방을 삭제하고 처음 화면으로
    private func deleteLesson() {
        isDeleting = true
        errorMessage = ""

        Task {
            do {
                try await FirestoreService.shared.deleteLesson(code: session.lessonCode)
                clearSessionAndWidget()
                onLeave()
            } catch {
                errorMessage = "레슨방 삭제에 실패했어요: \(error.localizedDescription)"
            }
            isDeleting = false
        }
    }

    /// 수강생: 기기에 저장된 세션만 지우고 처음 화면으로
    private func leaveLesson() {
        clearSessionAndWidget()
        onLeave()
    }

    private func clearSessionAndWidget() {
        LessonSession.clear()

        // 위젯에 남아 있는 레슨 날짜도 함께 비움
        let sharedDefaults = UserDefaults(suiteName: "group.Siye.LessonCalendar")
        sharedDefaults?.set([String](), forKey: "lessonDates")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview("대표") {
    NavigationStack {
        SettingsView(
            session: LessonSession(lessonName: "화목 배드민턴 레슨", lessonCode: "RALLY2026", role: .owner),
            onLeave: {}
        )
    }
}

#Preview("수강생") {
    NavigationStack {
        SettingsView(
            session: LessonSession(lessonName: "화목 배드민턴 레슨", lessonCode: "RALLY2026", role: .student),
            onLeave: {}
        )
    }
}
