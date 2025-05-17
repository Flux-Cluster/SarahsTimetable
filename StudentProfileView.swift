import SwiftUI

struct StudentProfileView: View {
    @EnvironmentObject var storageManager: StorageManager
    
    /// A string representing this student's name (e.g., "Alice Smith").
    /// We'll filter lessons by matching this `studentName` to each `Lesson.studentName`.
    let studentName: String

    @State private var notes: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // Notes Section
                Section(header: Text("Notes for \(studentName)").font(.headline)) {
                    TextEditor(text: $notes)
                        .frame(height: 150)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        // Whenever notes change, update in StorageManager
                        .onChange(of: notes) { newValue in
                            storageManager.updateStudentNotes(for: studentName, notes: newValue)
                        }
                }
                .padding()

                // Lessons List
                List {
                    if lessonsForStudent.isEmpty {
                        Text("No lessons found for this student.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(lessonsForStudent) { lesson in
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(formattedDate(lesson.date)) at \(lesson.time)")
                                    .font(.headline)
                                Text("Location: \(lesson.location)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                if let lessonNotes = lesson.notes, !lessonNotes.isEmpty {
                                    Text("Lesson Notes: \(lessonNotes)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle(studentName)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Load existing notes for this "name" if any
                notes = storageManager.studentNotes[studentName] ?? ""
            }
        }
    }

    /// Returns all lessons whose `lesson.studentName` matches the `studentName` for this view.
    private var lessonsForStudent: [Lesson] {
        storageManager.lessons.filter { $0.studentName == studentName }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct StudentProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a sample environment
        let storageManager = StorageManager()

        // Create a sample Student (optional if you just store the name in Lesson)
        let sampleStudent = Student(
            studentFirstName: "Alice",
            studentLastName: "Smith"
        )
        storageManager.students.append(sampleStudent)

        // Create a sample Lesson that stores the student's name directly
        let sampleLesson = Lesson(
            studentName: "Alice Smith",
            date: Date(),
            time: "10:00 AM",
            location: "Home",
            notes: "Focus on scales.",
            grade: 1
        )
        storageManager.lessons.append(sampleLesson)

        // Create a stored note for "Alice Smith"
        storageManager.studentNotes["Alice Smith"] = "Progressing well, working towards Grade 3 exam."

        // Now show the view for "Alice Smith"
        return StudentProfileView(studentName: "Alice Smith")
            .environmentObject(storageManager)
    }
}

