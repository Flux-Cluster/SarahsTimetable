import SwiftUI

struct PatternTestView: View {
    private let term: AcademicTerm = {
        let cal = Calendar.current
        let start = Date()
        let end = cal.date(byAdding: .day, value: 28, to: start) ?? start
        return AcademicTerm(schoolName: "Test School", startDate: start, endDate: end)
    }()

    private let pattern: PatternCycle = {
        let week1 = [
            PatternEntry(weekday: 2, hour: 9,  minute: 0),
            PatternEntry(weekday: 5, hour: 13, minute: 30)
        ]
        let week2 = [
            PatternEntry(weekday: 6, hour: 14, minute: 0)
        ]
        return PatternCycle(cycleLengthInWeeks: 2, weekPatterns: [week1, week2])
    }()

    private var generatedLessons: [(Date, Int, Int)] {
        AdvancedPatterns.generateLessons(from: pattern, in: term)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Term: \(fmt(term.startDate)) → \(fmt(term.endDate))")
                .font(.headline)
                .padding()

            List {
                ForEach(generatedLessons.indices, id: \.self) { i in
                    let (date, hr, min) = generatedLessons[i]
                    HStack {
                        Text(fmt(date))
                        Spacer()
                        Text(AdvancedPatterns.timeString(hour: hr, minute: min))
                    }
                }
            }
        }
        .navigationTitle("Pattern Test")
    }

    private func fmt(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: d)
    }
}

