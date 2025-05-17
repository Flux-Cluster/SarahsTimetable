import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum LessonStatus: String, Codable {
    case scheduled
    case attended
    case noShow
    case cancelled
}

struct Lesson: Identifiable, Codable {
    var id = UUID()

    // Store the student's name directly
    var studentName: String

    var date: Date
    var time: String
    var location: String
    var notes: String?
    var grade: Int
    var status: LessonStatus = .scheduled

    /// New property for tracking whether the lesson's fee has been paid.
    var feePaid: Bool = false

    // Category logic remains the same
    var category: String {
        switch grade {
        case 0...2: return "Beginner"
        case 3...5: return "Intermediate"
        default:    return "Advanced"
        }
    }

    var categoryColour: Color {
        switch category {
        case "Beginner":     return .green
        case "Intermediate": return .orange
        case "Advanced":     return .red
        default:             return .gray
        }
    }

    // For Drag & Drop, etc.
    static let lessonContentType = UTType(exportedAs: "com.yourdomain.sarahtimetable.lesson")
}

// MARK: - Transferable
extension Lesson: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: lessonContentType)
    }
}

// Optional string binding helper
extension Binding where Value == String? {
    var bound: Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}

// MARK: - Make Lesson Equatable
extension Lesson: Equatable {
    static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        lhs.id == rhs.id
    }
}

