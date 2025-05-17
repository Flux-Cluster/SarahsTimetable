import SwiftUI

/// Optional custom gold colour. If you prefer a different shade,
/// adjust the RGB values below or use .yellow.
extension Color {
    static let gold = Color(red: 0.85, green: 0.65, blue: 0.13)
}

struct TodayScheduleView: View {
    @EnvironmentObject var storageManager: StorageManager
    @State private var selectedDate = Date()
    @State private var showingAddLessonSheet = false
    @State private var selectedLessonForEdit: Lesson?
    @State private var selectedLessonForReschedule: Lesson?

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            VStack {
                // Date Picker Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select a Date")
                        .font(.headline)
                        .foregroundColor(AppColors.black)
                        .padding(.horizontal)

                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.horizontal)
                }

                // Lessons List
                List {
                    if lessonsForSelectedDate.isEmpty {
                        Text("No lessons for this date")
                            .foregroundColor(AppColors.black.opacity(0.8))
                            .listRowBackground(AppColors.creamyWhite)

                        Button("Add Lesson") {
                            showingAddLessonSheet = true
                        }
                        .foregroundColor(AppColors.black)
                        .listRowBackground(AppColors.creamyWhite)
                    } else {
                        ForEach(lessonsForSelectedDate, id: \.id) { lesson in
                            // Find the lesson in storageManager.lessons to allow editing
                            if let globalIndex = storageManager.lessons.firstIndex(where: { $0.id == lesson.id }) {

                                // Build a row with: Student info, Attended check, Fee Paid check
                                HStack(alignment: .center) {
                                    // Left side: lesson info
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(lesson.studentName)
                                            .font(.headline)
                                            .foregroundColor(AppColors.black)

                                        Text("\(formattedDate(lesson.date)) at \(lesson.time) - \(lesson.location)")
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.black.opacity(0.7))

                                        if let notes = lesson.notes, !notes.isEmpty {
                                            Text("Notes: \(notes)")
                                                .font(.footnote)
                                                .foregroundColor(AppColors.black.opacity(0.7))
                                        }

                                        // If status == .noShow, show that text in red
                                        if lesson.status == .noShow {
                                            Text("No-Show")
                                                .font(.footnote)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.vertical, 5)

                                    Spacer()

                                    // First: Attended check (green)
                                    Button(action: {
                                        toggleAttended(index: globalIndex)
                                    }) {
                                        Image(systemName: lesson.status == .attended ? "checkmark.square.fill" : "square")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(lesson.status == .attended ? .green : .gray)
                                    }
                                    .padding(.trailing, 10)

                                    // Second: Fee Paid check (gold)
                                    Button(action: {
                                        toggleFeePaid(index: globalIndex)
                                    }) {
                                        // If feePaid == true, show a filled check in gold
                                        Image(systemName: lesson.feePaid ? "checkmark.square.fill" : "square")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(lesson.feePaid ? .gold : .gray)
                                    }
                                }
                                // Keep the same background & swipe actions
                                .listRowBackground(AppColors.creamyWhite)
                                .swipeActions(edge: .trailing) {
                                    Button("Edit") {
                                        selectedLessonForEdit = storageManager.lessons[globalIndex]
                                    }
                                    .tint(.blue)

                                    Button("Reschedule") {
                                        selectedLessonForReschedule = storageManager.lessons[globalIndex]
                                    }
                                    .tint(.orange)
                                }

                            } else {
                                // If we can't find a global index, just show minimal info
                                Text(lesson.studentName)
                                    .foregroundColor(AppColors.black)
                                    .listRowBackground(AppColors.creamyWhite)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Lessons")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, .light)
        // Add new lesson
        .sheet(isPresented: $showingAddLessonSheet) {
            AddLessonView(lessons: $storageManager.lessons)
                .environmentObject(storageManager)
        }
        // Edit
        .sheet(item: $selectedLessonForEdit) { editingLesson in
            if let index = storageManager.lessons.firstIndex(where: { $0.id == editingLesson.id }) {
                EditLessonView(lesson: $storageManager.lessons[index])
                    .environmentObject(storageManager)
            } else {
                Text("Lesson not found.")
            }
        }
        // Reschedule
        .sheet(item: $selectedLessonForReschedule) { reschedulingLesson in
            if let index = storageManager.lessons.firstIndex(where: { $0.id == reschedulingLesson.id }) {
                RescheduleSheet(lesson: $storageManager.lessons[index])
                    .environmentObject(storageManager)
            } else {
                Text("Lesson not found.")
            }
        }
    }

    /// Lessons only for the selectedDate, sorted by date/time ascending
    private var lessonsForSelectedDate: [Lesson] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return storageManager.lessons
            .filter { $0.date >= startOfDay && $0.date < endOfDay }
            .sorted { $0.date < $1.date }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - Toggle Attended
    private func toggleAttended(index: Int) {
        let currentStatus = storageManager.lessons[index].status
        // If already .attended, revert to .scheduled; else set .attended
        if currentStatus == .attended {
            storageManager.lessons[index].status = .scheduled
        } else {
            storageManager.lessons[index].status = .attended
        }
        storageManager.updateLesson(storageManager.lessons[index])
    }

    // MARK: - Toggle Fee Paid
    private func toggleFeePaid(index: Int) {
        let isPaid = storageManager.lessons[index].feePaid
        // Flip the boolean
        storageManager.lessons[index].feePaid = !isPaid
        storageManager.updateLesson(storageManager.lessons[index])
    }
}

