import SwiftUI

/// 4. 수강생 코드 입력 화면 - 코드를 입력해 레슨방에 참여
struct JoinLessonView: View {
    /// 입장 성공 후 수강생용 캘린더 탭 화면으로 전환하기 위한 콜백
    var onEnter: (LessonSession) -> Void = { _ in }

    @State private var code: String = ""
    @State private var isJoining: Bool = false
    @State private var errorMessage: String = ""

    private var trimmedCode: String {
        code.trimmingCharacters(in: .whitespaces).uppercased()
    }

    var body: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("레슨 코드를 입력하세요")
                    .font(.headline)

                TextField("예: RALLY2026", text: $code)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3.monospaced())
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.go)
                    .onSubmit {
                        joinLesson()
                    }

                Text("대표에게 받은 레슨 코드를 입력하면 일정을 확인할 수 있어요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()

            Button {
                joinLesson()
            } label: {
                if isJoining {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("입장하기")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(trimmedCode.isEmpty || isJoining)
        }
        .padding(24)
        .navigationTitle("레슨 참여하기")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func joinLesson() {
        guard !trimmedCode.isEmpty, !isJoining else { return }

        isJoining = true
        errorMessage = ""

        Task {
            do {
                if let name = try await FirestoreService.shared.fetchLessonName(code: trimmedCode) {
                    // 다음 실행부터는 역할 선택 없이 바로 캘린더로 진입
                    let session = LessonSession(lessonName: name, lessonCode: trimmedCode, role: .student)
                    session.save()
                    onEnter(session)
                } else {
                    errorMessage = "해당 코드의 레슨방을 찾을 수 없어요. 코드를 다시 확인해주세요."
                }
            } catch {
                errorMessage = "레슨방 입장에 실패했어요: \(error.localizedDescription)"
            }
            isJoining = false
        }
    }
}

#Preview {
    NavigationStack {
        JoinLessonView()
    }
}
