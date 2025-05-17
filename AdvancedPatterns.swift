import Foundation

struct PatternEntry: Codable {
    var weekday: Int
    var hour: Int
    var minute: Int
}

struct PatternCycle: Codable {
    var cycleLengthInWeeks: Int
    var weekPatterns: [[PatternEntry]]
}

struct AdvancedPatterns {
    static func generateLessons(from pattern: PatternCycle, in term: AcademicTerm) -> [(Date, Int, Int)] {
        var results: [(Date, Int, Int)] = []
        let calendar = Calendar.current
        var current = term.startDate

        while current <= term.endDate {
            let weekday = calendar.component(.weekday, from: current)
            let weeksSinceStart = weeksBetween(calendar: calendar, start: term.startDate, end: current)
            let cycleWeekIndex = weeksSinceStart % pattern.cycleLengthInWeeks
            let entries = pattern.weekPatterns[cycleWeekIndex]

            for entry in entries {
                if entry.weekday == weekday {
                    var comps = calendar.dateComponents([.year, .month, .day], from: current)
                    comps.hour = entry.hour
                    comps.minute = entry.minute
                    if let lessonDate = calendar.date(from: comps) {
                        results.append((lessonDate, entry.hour, entry.minute))
                    }
                }
            }

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = nextDay
        }

        return results
    }

    private static func weeksBetween(calendar: Calendar, start: Date, end: Date) -> Int {
        let comps = calendar.dateComponents([.weekOfYear], from: start, to: end)
        return comps.weekOfYear ?? 0
    }

    static func timeString(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }
}

