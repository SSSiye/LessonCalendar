import Foundation
import SwiftData

@Model
final class ClickedDate {
    var date: Date
    
    init(date: Date) {
        self.date = date
    }
}
