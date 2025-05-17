import SwiftUI

struct RescheduleSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storageManager: StorageManager
    @Binding var lesson: Lesson

    @State private var selectedDate = Date()
    @State private var selectedSlot: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                Text("Reschedule Lesson")
                    .font(.title)
                    .padding()

                // Display the lesson’s student name directly:
                Text("Pick a new slot for \(lesson.studentName)")
                    .font(.headline)
                    .padding(.bottom)

                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(availableSlots(for: selectedDate), id: \.self) { slot in
                            let booked = isSlotBooked(slot, on: selectedDate)
                            Button(action: {
                                if !booked {
                                    selectedSlot = slot
                                }
                            }) {
                                Text(convertTo12HourFormat(slot))
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(slotColor(slot, booked: booked))
                                    .cornerRadius(10)
                            }
                            .disabled(booked)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Button("Save") {
                    guard let slot = selectedSlot else {
                        presentationMode.wrappedValue.dismiss()
                        return
                    }
                    // Update the lesson’s date & time
                    lesson.date = dateWithSlot(selectedDate, slot)
                    lesson.time = convertTo12HourFormat(slot)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .background((selectedSlot == nil) ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom)
            }
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    // MARK: - Available Slots
    private func availableSlots(for date: Date) -> [String] {
        let allSlots = StorageManager.halfHourTimeSlots()
        return allSlots.filter { storageManager.dailyAvailability[$0, default: true] }
    }

    private func isSlotBooked(_ slot: String, on date: Date) -> Bool {
        let chosen = dateWithSlot(date, slot)
        let timeStr = convertTo12HourFormat(slot)
        return !storageManager.isTimeSlotAvailable(
            date: chosen,
            time: timeStr,
            excludingLessonID: lesson.id
        )
    }

    private func slotColor(_ slot: String, booked: Bool) -> Color {
        if booked {
            return Color.red.opacity(0.7)
        } else if slot == selectedSlot {
            return Color.blue
        } else {
            return Color.gray.opacity(0.2)
        }
    }

    private func dateWithSlot(_ date: Date, _ slot: String) -> Date {
        let parts = slot.split(separator: ":")
        let hour = Int(parts.first ?? "9") ?? 9
        let minute = Int(parts.last ?? "0") ?? 0
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? date
    }

    private func convertTo12HourFormat(_ slot: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: slot) {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return slot
    }
}

