import SwiftUI

struct AddEnquiryView: View {
    @Binding var enquiries: [Enquiry]
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storageManager: StorageManager

    // Parent/Guardian details
    @State private var parentFirstName = ""
    @State private var parentLastName = ""

    // Student details
    @State private var studentFirstName = ""
    @State private var studentLastName = ""

    // Contact Info
    @State private var mobile = ""
    @State private var email = ""

    // Instrument (Picker)
    @State private var selectedInstrument = "Piano"
    private let instruments = ["Piano", "Clarinet"]

    @State private var notes = ""
    @State private var selectedSlot: Date? = nil
    @State private var selectedDate = Date() // Default to today for available slots
    @State private var showingSuccessAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Parent/Guardian Details
                    SectionHeader("Parent/Guardian Details")
                    VStack(spacing: 15) {
                        TextField("Parent/Guardian First Name", text: $parentFirstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Parent/Guardian Last Name", text: $parentLastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)

                    Divider()

                    // Student Details
                    SectionHeader("Student Details")
                    VStack(spacing: 15) {
                        TextField("Student First Name", text: $studentFirstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Student Last Name", text: $studentLastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)

                    Divider()

                    // Contact Info
                    SectionHeader("Contact Information")
                    VStack(spacing: 15) {
                        TextField("Mobile", text: $mobile)
                            .keyboardType(.phonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)

                    Divider()

                    // Instrument Picker
                    SectionHeader("Instrument")
                    Picker("Select Instrument", selection: $selectedInstrument) {
                        ForEach(instruments, id: \.self) { instrument in
                            Text(instrument).tag(instrument)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    Divider()

                    // Notes
                    SectionHeader("Notes")
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .padding(.horizontal)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)

                    Divider()

                    // Slot Viewer Section
                    SectionHeader("Available Slots for \(formattedDate(selectedDate))")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(allSlots(for: selectedDate), id: \.self) { slot in
                                let isBooked = isSlotBooked(slot, on: selectedDate)
                                Button(action: {
                                    if !isBooked {
                                        selectedSlot = slot
                                    }
                                }) {
                                    Text(formattedTime(slot))
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(slotBackgroundColor(slot: slot, booked: isBooked))
                                        .cornerRadius(10)
                                }
                                .disabled(isBooked)
                            }
                        }
                        .padding(.horizontal)
                    }

                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.horizontal)

                    // Save Button
                    Button(action: saveEnquiry) {
                        Text("Save Enquiry")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(parentNameCombined.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(parentNameCombined.isEmpty)

                    Spacer().frame(height: 50) // Extra space at the bottom for keyboard
                }
                .padding(.top, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("Add Enquiry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Enquiry Saved"),
                    message: Text("The enquiry has been successfully saved."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }

    // Computed property to combine first/last names
    private var parentNameCombined: String {
        let trimmedFirst = parentFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = parentLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedFirst.isEmpty && trimmedLast.isEmpty { return "" }
        return [trimmedFirst, trimmedLast].filter { !$0.isEmpty }.joined(separator: " ")
    }

    private var studentNameCombined: String {
        let trimmedFirst = studentFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = studentLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedFirst.isEmpty && trimmedLast.isEmpty { return "" }
        return [trimmedFirst, trimmedLast].filter { !$0.isEmpty }.joined(separator: " ")
    }

    private func saveEnquiry() {
        let chosenInstrument = selectedInstrument.isEmpty ? nil : selectedInstrument
        // Combine mobile and email into a single string for contactInfo
        let combinedContactInfo = (mobile.isEmpty && email.isEmpty) ? "" : "\(mobile)|\(email)"

        let newEnquiry = Enquiry(
            parentName: parentNameCombined,
            studentName: studentNameCombined,
            contactInfo: combinedContactInfo.isEmpty ? nil : combinedContactInfo,
            instrument: chosenInstrument,
            notes: notes.isEmpty ? nil : notes,
            slot: selectedSlot
        )
        enquiries.append(newEnquiry)
        showingSuccessAlert = true
    }

    private func allSlots(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        var slots: [Date] = []

        for hour in 9..<18 { // 9 AM to 5 PM
            for minute in [0, 30] {
                if let slot = calendar.date(byAdding: .minute, value: hour * 60 + minute, to: startOfDay) {
                    slots.append(slot)
                }
            }
        }
        return slots
    }

    private func isSlotBooked(_ slot: Date, on date: Date) -> Bool {
        let calendar = Calendar.current
        let bookedSlots = storageManager.lessons
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .map { $0.date }
        return bookedSlots.contains(slot)
    }

    private func slotBackgroundColor(slot: Date, booked: Bool) -> Color {
        if booked {
            return Color.red.opacity(0.7)
        } else if slot == selectedSlot {
            return Color.blue
        } else {
            return Color.gray.opacity(0.2)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func SectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.horizontal)
            .padding(.top, 10)
    }
}

struct AddEnquiryView_Previews: PreviewProvider {
    @State static var sampleEnquiries = [Enquiry]()

    static var previews: some View {
        AddEnquiryView(enquiries: $sampleEnquiries)
            .environmentObject(StorageManager())
    }
}

