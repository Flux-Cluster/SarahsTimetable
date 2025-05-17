import SwiftUI

struct LessonDetailView: View {
    @EnvironmentObject var storageManager: StorageManager

    // A binding to the selected lesson
    @Binding var lesson: Lesson

    @State private var editing = false

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Student: \(lesson.studentName)")
                        .font(.headline)
                        .foregroundColor(AppColors.black)

                    Text("Date: \(formattedDate(lesson.date))")
                        .foregroundColor(AppColors.black)

                    Text("Time: \(lesson.time)")
                        .foregroundColor(AppColors.black)

                    Text("Location: \(lesson.location)")
                        .foregroundColor(AppColors.black)

                    Text("Notes: \(lesson.notes ?? "None")")
                        .foregroundColor(AppColors.black)

                    Text("Status: \(lesson.status.rawValue.capitalized)")
                        .foregroundColor(AppColors.black)

                    Button(action: markNoShow) {
                        Text("Mark as No-Show")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }

                    Button("Edit Lesson") {
                        editing = true
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.black)
                    .padding(.top, 10)

                    Spacer().frame(height: 50)
                }
                .padding()
            }
        }
        .navigationTitle("Lesson Details")
        .navigationBarTitleDisplayMode(.inline)
        // Force light mode for readability
        .environment(\.colorScheme, .light)
        // Present EditLessonView directly
        .sheet(isPresented: $editing) {
            EditLessonView(lesson: $lesson)
                .environmentObject(storageManager)
        }
    }

    // MARK: - Actions
    private func markNoShow() {
        lesson.status = .noShow
        storageManager.updateLesson(lesson)
    }

    // MARK: - Helpers
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let storage = StorageManager()

        // Create a sample lesson that stores the student name directly
        let sampleLesson = Lesson(
            studentName: "Test Student",
            date: Date(),
            time: "10:00 AM",
            location: "Highsted",
            notes: "Sample notes",
            grade: 0
        )
        storage.lessons.append(sampleLesson)

        // Pass a binding to that lesson
        return LessonDetailView(lesson: .constant(sampleLesson))
            .environmentObject(storage)
    }
}

