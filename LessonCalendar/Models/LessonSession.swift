import Foundation

/// 사용자의 역할
enum LessonRole: String, Codable {
    case owner      // 대표
    case student    // 수강생
}

/// 참여 중인 레슨방 정보 - 기기에 저장해서 다음 실행 때 바로 캘린더로 진입
struct LessonSession: Codable {
    let lessonName: String
    let lessonCode: String
    let role: LessonRole

    private static let storageKey = "lessonSession"

    static func load() -> LessonSession? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(LessonSession.self, from: data)
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    /// 레슨방 삭제/나가기 시 호출 - 다음 실행 때 다시 역할 선택 화면부터 시작
    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
