import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var resultMessage: String = ""
    @State private var isSaving: Bool = false

    var body: some View {
        VStack {
            CalendarView()

            // Firestore 연결 테스트 UI
            VStack(spacing: 8) {
                Button {
                    saveTestLesson()
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Firestore 테스트 저장")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSaving)

                if !resultMessage.isEmpty {
                    Text(resultMessage)
                        .font(.caption)
                        .foregroundStyle(resultMessage.hasPrefix("✅") ? .green : .red)
                }
            }
            .padding()
        }
    }

    private func saveTestLesson() {
        isSaving = true
        resultMessage = ""

        Task {
            do {
                let documentID = try await FirestoreService.shared.saveTestLesson()
                resultMessage = "✅ 저장 성공! 문서 ID: \(documentID)"
            } catch {
                resultMessage = "❌ 저장 실패: \(error.localizedDescription)"
            }
            isSaving = false
        }
    }
}

#Preview {
    ContentView()
}
