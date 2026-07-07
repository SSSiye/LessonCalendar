import Foundation
import FirebaseFirestore

/// Firestore와의 데이터 통신을 담당하는 서비스
final class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()

    private init() {}

    /// lessons 컬렉션에 테스트 레슨 데이터를 저장
    /// - Returns: 저장된 문서의 ID
    @discardableResult
    func saveTestLesson() async throws -> String {
        let testLesson: [String: Any] = [
            "title": "테스트 레슨",
            "date": Timestamp(date: Date()),
            "studentName": "홍길동",
            "memo": "Firestore 연결 테스트",
            "createdAt": FieldValue.serverTimestamp()
        ]

        let reference = try await db.collection("lessons").addDocument(data: testLesson)
        return reference.documentID
    }
}
