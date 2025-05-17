import SwiftUI

struct DailyOverviewView: View {
    @EnvironmentObject var storageManager: StorageManager

    let lessons: [Lesson]

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedLessons.keys.sorted(), id: \.self) { date in
                    Section(header: Text(formattedDate(date))) {
                        ForEach(groupedLessons[date] ?? []) { lesson in
                            VStack(alignment: .leading) {
                                Text(lesson.studentName)
                                    .font(.headline)
                                Text("\(lesson.time) at \(lesson.location)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Daily Overview")
        }
    }

    // Group lessons by date
    private var groupedLessons: [Date: [Lesson]] {
        Dictionary(grouping: lessons) { lesson in
            Calendar.current.startOfDay(for: lesson.date)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DailyOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        let storage = StorageManager()

        // Create a sample Student
        let sampleStudent = Student(studentFirstName: "Test", studentLastName: "Student")
        storage.students.append(sampleStudent)

        // Create a sample Lesson storing just studentName
        let mockLesson = Lesson(
            studentName: "Test Student",
            date: Date(),
            time: "10:00 AM",
            location: "Highsted",
            notes: nil,
            grade: 1
        )

        return DailyOverviewView(lessons: [mockLesson])
            .environmentObject(storage) // needed for preview context
    }
}

