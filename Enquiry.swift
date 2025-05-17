import Foundation

// Enquiry represents a potential new student or a request for lessons
struct Enquiry: Identifiable, Codable {
    var id = UUID()
    var parentName: String
    var studentName: String?
    var contactInfo: String? // e.g. phone number or email
    var instrument: String?
    var notes: String?
    var slot: Date? // Optional time slot for scheduling
}

