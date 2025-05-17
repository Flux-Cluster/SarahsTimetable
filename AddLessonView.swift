import SwiftUI

enum StudentEntryMode: String, CaseIterable {
    case new = "New Student"
    case existing = "Existing Student"
}

struct AddLessonView: View {
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.presentationMode) var presentationMode

    @Binding var lessons: [Lesson]

    // Toggle between “New Student” or “Existing Student”
    @State private var studentEntryMode: StudentEntryMode = .new

    // For Existing Student selection
    @State private var selectedStudentID: UUID? = nil

    // Basic fields for building a *new* Student
    @State private var parentFirstName = ""
    @State private var parentLastName = ""
    @State private var studentFirstName = ""
    @State private var studentLastName = ""
    @State private var mobile = ""
    @State private var email = ""

    @State private var date = Date()
    @State private var selectedTimeSlot: String? = nil
    @State private var selectedInstrument = "Piano"
    private let instruments = ["Piano", "Clarinet"]

    @State private var notes = ""
    @State private var grade = 0
    @State private var selectedLocation = "Highsted"
    private let locations = ["Highsted", "Borden", "Student's House"]
    @State private var repeatWeekly = false

    @State private var showingBanner = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Add Lesson")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.black)
                        .padding(.top, 20)
                        .padding(.horizontal)

                    if showingBanner {
                        Text("Lesson Saved")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green.opacity(0.85))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                    }

                    // STUDENT ENTRY MODE PICKER
                    sectionHeader("Student Entry Mode")
                    Picker("Student Entry Mode", selection: $studentEntryMode) {
                        ForEach(StudentEntryMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // If user wants to add a brand-new student...
                    if studentEntryMode == .new {
                        sectionHeader("Parent/Guardian Details")
                        customTextField("Parent/Guardian First Name", text: $parentFirstName)
                        customTextField("Parent/Guardian Last Name", text: $parentLastName)

                        sectionHeader("Student Details")
                        customTextField("Student First Name", text: $studentFirstName)
                        customTextField("Student Last Name", text: $studentLastName)

                        sectionHeader("Contact Information")
                        customTextField("Mobile", text: $mobile, keyboardType: .phonePad)
                        customTextField("Email", text: $email, keyboardType: .emailAddress)
                    }
                    // Otherwise, show a picker of existing students
                    else {
                        sectionHeader("Select Existing Student")
                        if storageManager.students.isEmpty {
                            Text("No students found. Please add a student first.")
                                .font(.headline)
                                .foregroundColor(AppColors.black.opacity(0.8))
                                .padding(.horizontal)
                        } else {
                            Picker("Existing Students", selection: $selectedStudentID) {
                                ForEach(storageManager.students) { st in
                                    Text("\(st.studentFirstName) \(st.studentLastName)")
                                        .tag(st.id as UUID?)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(height: 100)
                            .background(AppColors.creamyWhite)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }

                    sectionHeader("Date and Time")
                    DatePicker("Select Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.horizontal)
                        .font(.body)
                        .foregroundColor(AppColors.black)
                        .background(AppColors.creamyWhite)
                        .cornerRadius(10)

                    Text("Select Time")
                        .font(.title3)
                        .foregroundColor(AppColors.black)
                        .padding(.horizontal)

                    wheelTimePicker

                    sectionHeader("Repeat Weekly?")
                    Toggle("Repeat this lesson every week?", isOn: $repeatWeekly)
                        .padding(.horizontal)
                        .toggleStyle(SwitchToggleStyle(tint: AppColors.rivieraGreen))

                    sectionHeader("Instrument")
                    Picker("Select Instrument", selection: $selectedInstrument) {
                        ForEach(instruments, id: \.self) { inst in
                            Text(inst).foregroundColor(AppColors.black)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    sectionHeader("Location")
                    Picker("Select Location", selection: $selectedLocation) {
                        ForEach(locations, id: \.self) { loc in
                            Text(loc).foregroundColor(AppColors.black)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    sectionHeader("Notes (Optional)")
                    TextEditor(text: $notes)
                        .font(.body)
                        .foregroundColor(AppColors.black)
                        .frame(height: 100)
                        .padding()
                        .background(AppColors.creamyWhite)
                        .cornerRadius(10)
                        .padding(.horizontal)

                    sectionHeader("Grade and Category")
                    Stepper("Grade: \(grade)", value: $grade, in: 0...8)
                        .font(.body)
                        .padding()
                        .background(AppColors.creamyWhite)
                        .cornerRadius(10)
                        .foregroundColor(AppColors.black)
                        .padding(.horizontal)

                    HStack {
                        Text("Category: \(category)")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                        Spacer()
                        Circle()
                            .fill(categoryColour)
                            .frame(width: 20, height: 20)
                    }
                    .padding()
                    .background(AppColors.creamyWhite)
                    .cornerRadius(10)
                    .padding(.horizontal)

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.horizontal, 20)
                    }

                    // SAVE BUTTON
                    Button(action: saveLesson) {
                        Text("Save Lesson")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            // *** Updated disabled logic:
                            .background(
                                ((studentEntryMode == .new && studentNameCombined.isEmpty)
                                 || (studentEntryMode == .existing && selectedStudentID == nil)
                                 || selectedTimeSlot == nil) ? Color.gray : AppColors.tyreRubber
                            )
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(
                        (studentEntryMode == .new && studentNameCombined.isEmpty)
                        || (studentEntryMode == .existing && selectedStudentID == nil)
                        || selectedTimeSlot == nil
                    )

                    Spacer().frame(height: 50)
                }
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.body)
                .foregroundColor(AppColors.black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, .light)
        .onAppear {
            // If there's exactly 1 student and we're in .existing mode,
            // optionally auto-select that student:
            if studentEntryMode == .existing,
               storageManager.students.count == 1 {
                selectedStudentID = storageManager.students.first?.id
            }
        }
    }

    // MARK: - Time Picker
    private var wheelTimePicker: some View {
        let allSlots = StorageManager.halfHourTimeSlots()
        let validSlots = allSlots.filter { storageManager.dailyAvailability[$0, default: true] }

        return VStack(alignment: .leading) {
            if validSlots.isEmpty {
                Text("No available slots. Update your availability.")
                    .font(.body)
                    .foregroundColor(AppColors.black)
                    .padding()
                    .background(AppColors.creamyWhite)
                    .cornerRadius(10)
                    .padding(.horizontal)
            } else {
                Picker("Select Time", selection: $selectedTimeSlot) {
                    ForEach(validSlots, id: \.self) { slot in
                        let isFree = storageManager.isTimeSlotAvailable(date: date, time: convertTo12HourFormat(slot))
                        let isUserAvail = storageManager.dailyAvailability[slot, default: true]
                        Text(slot + ((!isFree || !isUserAvail) ? " (unavailable)" : ""))
                            .tag(slot as String?)
                            .foregroundColor((isFree && isUserAvail) ? AppColors.black : .gray)
                            .disabled(!isFree || !isUserAvail)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(AppColors.creamyWhite)
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Save Lesson
    private func saveLesson() {
        guard let chosenSlot = selectedTimeSlot else {
            errorMessage = "Please select a time slot."
            return
        }

        let chosenDate = dateWithTimeSlot(date, chosenSlot)
        let timeString = convertTo12HourFormat(chosenSlot)
        let isFree = storageManager.isTimeSlotAvailable(date: chosenDate, time: timeString)
        if !isFree {
            errorMessage = "That slot is taken by another student."
            return
        }

        // 1) Build the final student name
        let finalStudentName: String
        switch studentEntryMode {
        case .new:
            // Create new Student & append to storage
            let newStudent = Student(
                studentFirstName: studentFirstName.trimmingCharacters(in: .whitespacesAndNewlines),
                studentLastName: studentLastName.trimmingCharacters(in: .whitespacesAndNewlines),
                parentFirstName: parentFirstName.isEmpty ? nil : parentFirstName,
                parentLastName: parentLastName.isEmpty ? nil : parentLastName,
                mobile: mobile.isEmpty ? nil : mobile,
                email: email.isEmpty ? nil : email
            )
            storageManager.students.append(newStudent)
            finalStudentName = studentNameCombined

        case .existing:
            guard let selectedID = selectedStudentID,
                  let existing = storageManager.students.first(where: { $0.id == selectedID })
            else {
                errorMessage = "Please select an existing student."
                return
            }
            let first = existing.studentFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let last  = existing.studentLastName.trimmingCharacters(in: .whitespacesAndNewlines)
            finalStudentName = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        }

        // 2) Create a new Lesson
        let newLesson = Lesson(
            studentName: finalStudentName,
            date: chosenDate,
            time: timeString,
            location: selectedLocation,
            notes: notes.isEmpty ? nil : notes,
            grade: grade
        )
        lessons.append(newLesson)

        // 3) If repeatWeekly is on, add a recurring pattern
        if repeatWeekly {
            let cal = Calendar.current
            let wd = cal.component(.weekday, from: chosenDate)
            let c = cal.dateComponents([.hour, .minute], from: chosenDate)
            let hr = c.hour ?? 9
            let min = c.minute ?? 0

            let newPattern = RecurringLessonPattern(
                studentName: finalStudentName,
                weekday: wd,
                hour: hr,
                minute: min,
                location: selectedLocation,
                notes: notes.isEmpty ? nil : notes,
                instrument: selectedInstrument,
                grade: grade
            )
            storageManager.addRecurringPattern(newPattern)
        }

        // Show success banner, then dismiss
        errorMessage = nil
        withAnimation { showingBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showingBanner = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    // MARK: - Derived Values
    private var studentNameCombined: String {
        let tf = studentFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let tl = studentLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        if tf.isEmpty && tl.isEmpty { return "" }
        return [tf, tl].filter { !$0.isEmpty }.joined(separator: " ")
    }

    private var category: String {
        switch grade {
        case 0...2: return "Beginner"
        case 3...5: return "Intermediate"
        default:    return "Advanced"
        }
    }

    private var categoryColour: Color {
        switch category {
        case "Beginner":     return .green
        case "Intermediate": return .orange
        default:             return .red
        }
    }

    // MARK: - Utilities
    private func dateWithTimeSlot(_ d: Date, _ slot: String) -> Date {
        let parts = slot.split(separator: ":")
        let hour = Int(parts.first ?? "9") ?? 9
        let minute = Int(parts.last ?? "0") ?? 0
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: d)
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? d
    }

    private func convertTo12HourFormat(_ slot: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        if let date = f.date(from: slot) {
            f.timeStyle = .short
            return f.string(from: date)
        }
        return slot
    }

    // For consistent styling on your section headers
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(AppColors.black)
            .padding(.horizontal)
    }

    private func customTextField(
        _ placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        TextField(placeholder, text: text)
            .font(.body)
            .padding()
            .keyboardType(keyboardType)
            .foregroundColor(AppColors.black)
            .background(AppColors.creamyWhite)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

