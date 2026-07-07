import Foundation
import FirebaseFirestore

/// Firestore와의 데이터 통신을 담당하는 서비스
final class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()

    private init() {}

    /// 레슨 코드 자동 생성 (예: RALLY2026 형식 - 영문 5자 + 숫자 4자)
    static func generateLessonCode() -> String {
        // 혼동되기 쉬운 문자(I, O, 0, 1)는 제외
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let digits = "23456789"
        let letterPart = String((0..<5).compactMap { _ in letters.randomElement() })
        let digitPart = String((0..<4).compactMap { _ in digits.randomElement() })
        return letterPart + digitPart
    }

    /// 해당 코드로 만들어진 레슨방이 이미 있는지 확인
    func lessonExists(code: String) async throws -> Bool {
        let snapshot = try await db.collection("lessons").document(code).getDocument()
        return snapshot.exists
    }

    /// 레슨방 생성 - 레슨 코드를 문서 ID로 사용해서 코드 조회가 바로 가능하게 함
    /// - Returns: 확정된 레슨 코드 (코드가 중복이면 새로 생성해서 저장)
    func createLesson(name: String, code: String) async throws -> String {
        var finalCode = code

        // 코드 중복 시 최대 5번까지 재생성
        for _ in 0..<5 {
            if try await lessonExists(code: finalCode) {
                finalCode = Self.generateLessonCode()
            } else {
                break
            }
        }

        let data: [String: Any] = [
            "name": name,
            "code": finalCode,
            "lessonDates": [],
            "createdAt": FieldValue.serverTimestamp()
        ]

        try await db.collection("lessons").document(finalCode).setData(data)
        return finalCode
    }

    /// 레슨 날짜 저장 - "yyyy-MM-dd" 문자열 배열로 lessonDates 필드를 통째로 교체
    func updateLessonDates(code: String, dates: [String]) async throws {
        try await db.collection("lessons").document(code).updateData([
            "lessonDates": dates
        ])
    }

    /// 레슨 날짜 조회 - 수강생/대표가 캘린더를 열 때 사용
    func fetchLessonDates(code: String) async throws -> [String] {
        let snapshot = try await db.collection("lessons").document(code).getDocument()
        return snapshot.data()?["lessonDates"] as? [String] ?? []
    }
}
