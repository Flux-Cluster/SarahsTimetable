import SwiftUI

struct SelectedLessonInfo: Identifiable {
    let id = UUID()
    var lesson: Lesson
    var dayIndex: Int
    var slotIndex: Int
}

struct WeeklyPlannerView: View {
    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let slots = StorageManager.halfHourTimeSlots()

    @EnvironmentObject var storageManager: StorageManager

    @State private var schedule: [[Lesson?]] = []
    @State private var selectedLessonInfo: SelectedLessonInfo? = nil
    @State private var showingSlotTakenAlert = false

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Top row: day labels
                        HStack(spacing: 1) {
                            Color.clear.frame(width: 75, height: 35)
                            ForEach(days, id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.black)
                                    .frame(width: 50, height: 35)
                                    .background(AppColors.creamyWhite)
                            }
                        }

                        ScrollView {
                            ForEach(slots.indices, id: \.self) { slotIndex in
                                HStack(spacing: 1) {
                                    // Time slot label
                                    Text(slots[slotIndex])
                                        .font(.system(size: 10))
                                        .foregroundColor(AppColors.black)
                                        .frame(width: 75, height: 45)
                                        .background(AppColors.creamyWhite)

                                    // 7 days
                                    ForEach(0..<days.count, id: \.self) { dayIndex in
                                        cellView(dayIndex: dayIndex, slotIndex: slotIndex)
                                            .frame(width: 50, height: 45)
                                            .background(AppColors.creamyWhite)
                                            .border(AppColors.black.opacity(0.1))
                                            .onTapGesture {
                                                if let lesson = schedule[safe: dayIndex]?[safe: slotIndex],
                                                   let realLesson = lesson {
                                                    selectedLessonInfo = SelectedLessonInfo(
                                                        lesson: realLesson,
                                                        dayIndex: dayIndex,
                                                        slotIndex: slotIndex
                                                    )
                                                }
                                            }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        // Tapping a lesson opens this sheet
        .sheet(item: $selectedLessonInfo) { selected in
            StatefulSheetView(
                selected: selected,
                schedule: $schedule,
                days: days,
                slots: slots,
                showingSlotTakenAlert: $showingSlotTakenAlert,
                onDismiss: { selectedLessonInfo = nil }
            )
            .environmentObject(storageManager)
        }
        .alert("Slot Unavailable", isPresented: $showingSlotTakenAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The selected time slot is already taken by another student. Please choose a different slot.")
        }
        // For iOS 17 style onChange with two-parameter closure
        .onChange(of: storageManager.lessons) { oldValue, newValue in
            fillSchedule()
        }
        .onAppear {
            fillSchedule()
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            Text("Weekly Planner")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.black)
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private func cellView(dayIndex: Int, slotIndex: Int) -> some View {
        guard dayIndex < schedule.count, slotIndex < schedule[dayIndex].count else {
            return AnyView(Color.clear)
        }
        if let lesson = schedule[dayIndex][slotIndex] {
            return AnyView(lessonView(lesson))
        } else {
            return AnyView(Color.clear)
        }
    }

    private func lessonView(_ lesson: Lesson) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(lesson.categoryColour)
                .frame(width: 8, height: 8)
            // Display lesson.studentName directly
            Text(lesson.studentName)
                .font(.system(size: 10))
                .foregroundColor(AppColors.black)
                .lineLimit(1)
            Spacer()
        }
        .padding(3)
    }

    private func fillSchedule() {
        let dayCount = days.count
        let slotCount = slots.count
        var newSchedule = Array(
            repeating: Array(repeating: Lesson?.none, count: slotCount),
            count: dayCount
        )

        for lesson in storageManager.lessons {
            let dIndex = dayIndex(for: lesson.date)
            let slotKey = convertTo24Hour(lesson.time)
            if let sIndex = slots.firstIndex(of: slotKey),
               dIndex >= 0 && dIndex < dayCount {
                newSchedule[dIndex][sIndex] = lesson
            }
        }
        schedule = newSchedule
    }

    private func dayIndex(for date: Date) -> Int {
        // Sunday=1, Monday=2, etc. We want Monday=0...Sunday=6
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return (weekday + 5) % 7
    }

    private func convertTo24Hour(_ timeString: String) -> String {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        if let date = df.date(from: timeString) {
            let df2 = DateFormatter()
            df2.dateFormat = "HH:mm"
            return df2.string(from: date)
        }
        return timeString
    }
}

// Safe subscript extension
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

