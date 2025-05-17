import SwiftUI

struct EditLessonView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storageManager: StorageManager

    // A binding to the selected lesson object
    @Binding var lesson: Lesson

    // We'll store the typed name locally (since Lesson now directly has `studentName`).
    @State private var typedStudentName = ""

    @State private var selectedLocation = "Highsted"
    private let locations = ["Highsted", "Borden", "Student's House"]

    // Instead of a DatePicker for time, we’ll use a slot-based picker as in AddLessonView
    @State private var selectedSlot: String? = nil
    @State private var showingSlotConflictAlert = false
    @State private var showingUnavailableAlert = false

    @State private var originalDate = Date()
    @State private var originalSelectedSlot: String? = nil

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Edit Lesson")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.black)
                        .padding(.top, 20)
                        .padding(.horizontal)

                    // STUDENT NAME
                    TextField("Student's name", text: $typedStudentName)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .foregroundColor(AppColors.black)
                        .padding()
                        .background(AppColors.creamyWhite)
                        .cornerRadius(10)
                        .padding(.horizontal)

                    // DATE & TIME SECTION
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Date and Time")
                            .font(.headline)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        DatePicker("Date", selection: $lesson.date, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .tint(.black)
                            .padding()
                            .background(AppColors.creamyWhite)
                            .cornerRadius(10)
                            .padding(.horizontal)

                        HStack {
                            Text("Select Time")
                                .foregroundColor(AppColors.black)
                                .padding(.leading)
                            Spacer()
                        }

                        // Use a picker for available half-hour slots
                        Picker("Select Time Slot", selection: $selectedSlot) {
                            ForEach(availableSlots, id: \.self) { slot in
                                Text(convertTo12HourFormat(slot))
                                    .foregroundColor(AppColors.black)
                                    .tag(slot as String?)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(AppColors.creamyWhite)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // LOCATION PICKER
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Location")
                            .font(.headline)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Picker("Select Location", selection: $selectedLocation) {
                            ForEach(locations, id: \.self) { location in
                                Text(location)
                                    .foregroundColor(AppColors.black)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .background(AppColors.creamyWhite)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onChange(of: selectedLocation) { newVal in
                            lesson.location = newVal
                        }
                    }

                    // NOTES
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes (Optional)")
                            .font(.headline)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        TextEditor(
                            text: Binding<String>(
                                get: { lesson.notes ?? "" },
                                set: { lesson.notes = $0.isEmpty ? nil : $0 }
                            )
                        )
                        .foregroundColor(AppColors.black)
                        .frame(height: 100)
                        .padding()
                        .background(AppColors.creamyWhite)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // GRADE & CATEGORY
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Grade and Category")
                            .font(.headline)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Stepper("Grade: \(lesson.grade)", value: $lesson.grade, in: 0...8)
                            .padding()
                            .background(AppColors.creamyWhite)
                            .cornerRadius(10)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        HStack {
                            Text("Category: \(lesson.category)")
                                .foregroundColor(AppColors.black)
                            Spacer()
                            Circle()
                                .fill(lesson.categoryColour)
                                .frame(width: 20, height: 20)
                        }
                        .padding()
                        .background(AppColors.creamyWhite)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // SAVE BUTTON
                    Button("Save") {
                        saveLesson()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.tyreRubber)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                    Spacer().frame(height: 50)
                }
                .padding(.bottom, 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.black)
            }
        }
        // ALERTS
        .alert("Slot Unavailable", isPresented: $showingSlotConflictAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The selected time slot is already taken by another student. Please choose a different date or time.")
        }
        .alert("Time Unavailable", isPresented: $showingUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You have marked this half-hour slot as unavailable. Please pick a different time.")
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Populate typedStudentName from the lesson's studentName
            typedStudentName = lesson.studentName

            // Set up location & time slot
            selectedLocation = lesson.location
            if let slot = slotFromTime(lesson.time) {
                selectedSlot = slot
                originalSelectedSlot = slot
            } else {
                selectedSlot = availableSlots.first
                originalSelectedSlot = selectedSlot
            }
            originalDate = lesson.date
        }
        .environment(\.colorScheme, .light)
    }

    // MARK: - Available Time Slots
    private var availableSlots: [String] {
        let allSlots = StorageManager.halfHourTimeSlots()
        return allSlots.filter { storageManager.dailyAvailability[$0] == true }
    }

    // MARK: - Save Lesson
    private func saveLesson() {
        guard let chosenSlot = selectedSlot else {
            // No slot chosen, can't save
            return
        }

        // Check if chosenSlot is available (not disabled by dailyAvailability)
        if let isAvail = storageManager.dailyAvailability[chosenSlot], !isAvail {
            showingUnavailableAlert = true
            return
        }

        // Convert chosenSlot to time string
        let newTimeString = convertTo12HourFormat(chosenSlot)
        let dateChanged = lesson.date != originalDate
        let timeChanged = newTimeString != lesson.time

        // Update lesson with typed name and new time
        lesson.studentName = typedStudentName
        lesson.time = newTimeString
        lesson.location = selectedLocation

        // Check for conflicts only if date/time changed
        if dateChanged || timeChanged {
            if storageManager.isTimeSlotAvailable(date: lesson.date, time: lesson.time, excludingLessonID: lesson.id) {
                storageManager.updateLesson(lesson)
                presentationMode.wrappedValue.dismiss()
            } else {
                showingSlotConflictAlert = true
            }
        } else {
            // Just update
            storageManager.updateLesson(lesson)
            presentationMode.wrappedValue.dismiss()
        }
    }

    // MARK: - Helpers
    private func slotFromTime(_ timeString: String) -> String? {
        // Convert the timeString (e.g. "9:30 AM") back to a 24-hour slot like "09:30"
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        if let date = formatter.date(from: timeString) {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
            let hour = comps.hour ?? 9
            let minute = comps.minute ?? 0
            return String(format: "%02d:%02d", hour, minute)
        }
        return nil
    }

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

