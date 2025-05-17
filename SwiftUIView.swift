import Foundation

struct RecurringLessonPattern: Identifiable, Codable {
    var id = UUID()
    var studentName: String
    var weekday: Int   // 1 = Sunday, 2 = Monday, etc.
    var hour: Int
    var minute: Int
    var location: String
    var notes: String?
    var instrument: String? // Added instrument property
    var grade: Int
}

