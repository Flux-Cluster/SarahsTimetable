import SwiftUI

struct StatefulSheetView: View {
    var selected: SelectedLessonInfo
    @Binding var schedule: [[Lesson?]]
    let days: [String]
    let slots: [String]

    @Binding var showingSlotTakenAlert: Bool

    @State private var newDayIndex: Int
    @State private var newSlotIndex: Int

    @EnvironmentObject var storageManager: StorageManager
    @State private var editingLesson: Lesson? = nil

    var onDismiss: () -> Void

    init(
        selected: SelectedLessonInfo,
        schedule: Binding<[[Lesson?]]>,
        days: [String],
        slots: [String],
        showingSlotTakenAlert: Binding<Bool>,
        onDismiss: @escaping () -> Void
    ) {
        self.selected = selected
        self._schedule = schedule
        self.days = days
        self.slots = slots
        self._showingSlotTakenAlert = showingSlotTakenAlert
        self.onDismiss = onDismiss

        _newDayIndex = State(initialValue: selected.dayIndex)
        _newSlotIndex = State(initialValue: selected.slotIndex)
    }

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Edit Lesson Slot")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.black)
                        .padding(.top, 20)

                    let currentLesson = selected.lesson

                    // Display the lesson's studentName
                    Text("Current Lesson: \(currentLesson.studentName)")
                        .font(.headline)
                        .foregroundColor(AppColors.black)

                    if !currentLesson.location.isEmpty {
                        Text("Location: \(currentLesson.location)")
                            .font(.subheadline)
                            .foregroundColor(AppColors.black.opacity(0.8))
                    }

                    if let notes = currentLesson.notes, !notes.isEmpty {
                        Text("Notes: \(notes)")
                            .font(.subheadline)
                            .foregroundColor(AppColors.black.opacity(0.7))
                    }

                    // Select new day
                    Text("Select New Day:")
                        .font(.subheadline)
                        .foregroundColor(AppColors.black)
                    Picker("Day", selection: $newDayIndex) {
                        ForEach(0..<days.count, id: \.self) { i in
                            Text(days[i]).tag(i)
                                .foregroundColor(AppColors.black)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // Select new time slot
                    Text("Select New Time Slot:")
                        .font(.subheadline)
                        .foregroundColor(AppColors.black)
                    Picker("Slot", selection: $newSlotIndex) {
                        ForEach(0..<slots.count, id: \.self) { i in
                            Text(convertTo12HourFormat(slots[i]))
                                .foregroundColor(AppColors.black)
                                .tag(i)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 150)
                    .background(AppColors.creamyWhite)
                    .cornerRadius(10)

                    // Buttons row (Cancel lesson, or Move lesson)
                    HStack {
                        Button(action: {
                            // “Cancel the lesson” both locally and in storage
                            schedule[selected.dayIndex][selected.slotIndex] = nil
                            removeLessonFromStorage(currentLesson)
                            onDismiss()
                        }) {
                            Text("Cancel Lesson")
                                .foregroundColor(.red)
                        }
                        Spacer()
                        Button(action: {
                            // Move the lesson to the new slot
                            let oldDay = selected.dayIndex
                            let oldSlot = selected.slotIndex

                            let currentLesson = selected.lesson
                            schedule[newDayIndex][newSlotIndex] = currentLesson
                            schedule[oldDay][oldSlot] = nil
                            // (Optional) If you want to actually update
                            // the lesson's date/time in storage, you could do so here.
                            onDismiss()
                        }) {
                            Text("Save")
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.black)
                        }
                    }

                    // Full Edit
                    Button("Full Edit") {
                        editingLesson = currentLesson
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.tyreRubber)

                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarItems(leading: Button("Dismiss") {
            onDismiss()
        })
        .navigationBarTitleDisplayMode(.inline)
        // Show EditLessonView if editingLesson is set
        .sheet(item: $editingLesson) { lessonToEdit in
            if let index = storageManager.lessons.firstIndex(where: { $0.id == lessonToEdit.id }) {
                EditLessonView(lesson: $storageManager.lessons[index])
                    .environmentObject(storageManager)
            } else {
                Text("Lesson not found")
            }
        }
    }

    // MARK: - Remove the Lesson from Storage
    private func removeLessonFromStorage(_ lesson: Lesson) {
        if let index = storageManager.lessons.firstIndex(where: { $0.id == lesson.id }) {
            storageManager.lessons.remove(at: index)
        }
    }

    // MARK: - Convert Time Slot
    private func convertTo12HourFormat(_ slot: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let d = formatter.date(from: slot) {
            formatter.timeStyle = .short
            return formatter.string(from: d)
        }
        return slot
    }
}

