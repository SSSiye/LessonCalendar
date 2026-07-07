import SwiftUI
import FirebaseCore

@main
struct LessonCalendarApp: App {
    init() {
        FirebaseApp.configure()
    }
       
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
