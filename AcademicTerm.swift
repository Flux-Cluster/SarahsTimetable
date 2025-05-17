import Foundation

/// A basic struct for each academic term (start, end, plus the school name).
/// It's used inside `AcademicTermData` in StorageManager.
struct AcademicTerm: Codable {
    var schoolName: String  // e.g. "Highsted", "Borden", or others
    var startDate: Date
    var endDate: Date
}

/// If you prefer, you can also define `AcademicTermData` here,
// but you already have it in StorageManager:
//
// struct AcademicTermData: Codable, Identifiable {
//     var id = UUID()
//     var term: AcademicTerm
//     var patternCycles: [PatternCycle] = []
// }

