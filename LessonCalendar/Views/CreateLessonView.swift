import SwiftUI

/// 2. 레슨 코드 생성 화면 - 대표가 레슨방을 만드는 화면
struct CreateLessonView: View {
    /// 레슨방 생성 완료 후 캘린더 탭 화면으로 전환하기 위한 콜백
    var onEnter: (LessonSession) -> Void = { _ in }

    @State private var lessonName: String = ""
    @State private var lessonCode: String = FirestoreService.generateLessonCode()
    @State private var isCreating: Bool = false
    @State private var isCreated: Bool = false
    @State private var errorMessage: String = ""

    private var trimmedName: String {
        lessonName.trimmingCharacters(in: .whitespaces)
    }

    /// 공유 시트로 보낼 초대 메시지
    private var shareMessage: String {
        """
        『\(trimmedName)』 레슨에 초대해요! 🏸
        레슨 캘린더 앱에서 아래 코드를 입력하면 일정을 확인할 수 있어요.

        레슨 코드: \(lessonCode)
        """
    }

    var body: some View {
        VStack(spacing: 32) {
            if isCreated {
                createdView
            } else {
                inputView
            }
        }
        .padding(24)
        .navigationTitle("레슨 만들기")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 생성 전: 레슨 이름 입력

    private var inputView: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("레슨 이름")
                    .font(.headline)

                TextField("예: 화목 배드민턴 레슨", text: $lessonName)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("레슨 코드")
                    .font(.headline)

                HStack {
                    Text(lessonCode)
                        .font(.title2.monospaced())
                        .fontWeight(.bold)

                    Spacer()

                    // 코드 새로고침
                    Button {
                        lessonCode = FirestoreService.generateLessonCode()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .padding()
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))

                Text("코드는 자동으로 생성돼요. 수강생이 이 코드로 참여해요.")
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
                createLesson()
            } label: {
                if isCreating {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("레슨방 만들기")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(trimmedName.isEmpty || isCreating)
        }
    }

    // MARK: - 생성 후: 코드 확인 + 공유

    private var createdView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)

                Text("레슨방이 만들어졌어요!")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(trimmedName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // 레슨 코드 카드
            VStack(spacing: 8) {
                Text("레슨 코드")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(lessonCode)
                    .font(.largeTitle.monospaced())
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))

            Spacer()

            VStack(spacing: 12) {
                ShareLink(item: shareMessage) {
                    Label("수강생에게 공유하기", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    onEnter(LessonSession(lessonName: trimmedName, lessonCode: lessonCode, role: .owner))
                } label: {
                    Text("캘린더 시작하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }

    private func createLesson() {
        isCreating = true
        errorMessage = ""

        Task {
            do {
                // 코드 중복 시 서비스가 새 코드를 만들어 반환하므로 화면에 반영
                lessonCode = try await FirestoreService.shared.createLesson(
                    name: trimmedName,
                    code: lessonCode
                )
                // 다음 실행부터는 역할 선택 없이 바로 캘린더로 진입
                LessonSession(lessonName: trimmedName, lessonCode: lessonCode, role: .owner).save()
                isCreated = true
            } catch {
                errorMessage = "레슨방 생성에 실패했어요: \(error.localizedDescription)"
            }
            isCreating = false
        }
    }
}

#Preview {
    NavigationStack {
        CreateLessonView()
    }
}
