import SwiftUI

struct EnquiryDetailView: View {
    @EnvironmentObject var storageManager: StorageManager
    
    var enquiry: Enquiry
    
    @State private var startDate = Date()
    @State private var showingConfirmationAlert = false
    @State private var selectedSlotDate: Date?
    @State private var selectedSlotTime: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Enquiry details
            Text("Parent: \(enquiry.parentName)")
                .font(.headline)

            if let sName = enquiry.studentName {
                Text("Student: \(sName)")
                    .font(.subheadline)
            } else {
                Text("Student: N/A")
                    .font(.subheadline)
            }

            if let contact = enquiry.contactInfo {
                Text("Contact: \(contact)")
                    .font(.subheadline)
            } else {
                Text("Contact: N/A")
                    .font(.subheadline)
            }

            if let instrument = enquiry.instrument {
                Text("Instrument: \(instrument)")
                    .font(.subheadline)
            } else {
                Text("Instrument: N/A")
                    .font(.subheadline)
            }

            if let notes = enquiry.notes {
                Text("Notes: \(notes)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Notes: N/A")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider().padding(.vertical, 10)

            // Weekly schedule section
            Text("Select a free slot to book a lesson:")
                .font(.headline)

            List {
                ForEach(0..<7, id: \.self) { offset in
                    let dayDate = Calendar.current.date(byAdding: .day, value: offset, to: startDate)!
                    Section(header: Text(formattedDate(dayDate))) {
                        let daySlots = generateTimeSlots(for: dayDate)
                        if daySlots.isEmpty {
                            Text("No lessons (all day free)")
                                .foregroundColor(.secondary)
                                .onTapGesture {
                                    selectedSlotDate = dayDate
                                    selectedSlotTime = "10:00 AM" // Default time
                                    showingConfirmationAlert = true
                                }
                        } else {
                            ForEach(daySlots, id: \.time) { slot in
                                if slot.isFree {
                                    Text("Available slot at \(slot.time)")
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            selectedSlotDate = dayDate
                                            selectedSlotTime = slot.time
                                            showingConfirmationAlert = true
                                        }
                                } else {
                                    // Show the occupying lesson's studentName
                                    Text("\(slot.lessonName) at \(slot.time)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        startDate = Date()
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Enquiry Details")
        .alert(isPresented: $showingConfirmationAlert) {
            Alert(
                title: Text("Confirm Booking"),
                message: Text(
                    "Book a lesson for \(enquiry.studentName ?? "the student") " +
                    "at \(selectedSlotTime ?? "this time") on \(formattedDate(selectedSlotDate ?? Date()))?"
                ),
                primaryButton: .default(Text("Confirm"), action: {
                    bookLesson()
                }),
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: - Generate time slots for the day
    private func generateTimeSlots(for date: Date) -> [TimeSlot] {
        // 9 AM to 5 PM
        let hours = Array(9...17)
        let dayLessons = lessonsForDay(date)

        return hours.map { hour -> TimeSlot in
            // Construct the time string (e.g. "9:00 AM")
            let slotDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: date)!
            let timeString = timeStringFromDate(slotDate)

            // See if there's an existing lesson at this time
            if let occupiedLesson = dayLessons.first(where: { $0.time == timeString }) {
                // Just show the name from the Lesson directly
                let name = occupiedLesson.studentName
                return TimeSlot(time: timeString, isFree: false, lessonName: name)
            } else {
                return TimeSlot(time: timeString, isFree: true, lessonName: "")
            }
        }
    }

    private func lessonsForDay(_ date: Date) -> [Lesson] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return storageManager.lessons.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func timeStringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Book lesson
    private func bookLesson() {
        guard let slotDate = selectedSlotDate,
              let slotTime = selectedSlotTime else { return }

        // 1) Create a new student from the enquiry
        let newStudent = Student(
            studentFirstName: enquiry.studentName ?? "Unknown",
            studentLastName: "", // You can leave lastName empty or parse it if needed
            parentFirstName: enquiry.parentName,
            parentLastName: nil,
            mobile: enquiry.contactInfo,
            email: nil
        )
        storageManager.students.append(newStudent)

        // Combine the student's first + last name to store in the Lesson
        let combinedName = [
            newStudent.studentFirstName,
            newStudent.studentLastName
        ]
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " ")

        // 2) Create a new Lesson storing the studentName
        let newLesson = Lesson(
            studentName: combinedName.isEmpty ? "Unknown" : combinedName,
            date: slotDate,
            time: slotTime,
            location: "TBD", // Sarah can update manually later
            notes: enquiry.notes,
            grade: 0
        )
        storageManager.lessons.append(newLesson)

        // 3) Remove this enquiry from the storage (as it's now booked)
        if let idx = storageManager.enquiries.firstIndex(where: { $0.id == enquiry.id }) {
            storageManager.enquiries.remove(at: idx)
        }
    }
}

// MARK: - TimeSlot
struct TimeSlot {
    let time: String
    let isFree: Bool
    let lessonName: String
}

struct EnquiryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEnquiry = Enquiry(
            parentName: "Jane Doe",
            studentName: "Emily Doe",
            contactInfo: "jane@example.com",
            instrument: "Piano",
            notes: "Interested in weekly lessons."
        )
        return EnquiryDetailView(enquiry: sampleEnquiry)
            .environmentObject(StorageManager())
    }
}

