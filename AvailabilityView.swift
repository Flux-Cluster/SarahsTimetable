import SwiftUI

struct AvailabilityView: View {
    @EnvironmentObject var storageManager: StorageManager

    private let timeSlots = StorageManager.halfHourTimeSlots()

    var body: some View {
        VStack {
            Text("Edit Daily Availability")
                .font(.title)
                .padding()

            List {
                ForEach(timeSlots, id: \.self) { slot in
                    HStack {
                        Text(slot)
                            .font(.body)
                        Spacer()
                        Toggle("Available", isOn: bindingForSlot(slot))
                            .labelsHidden()
                    }
                    .listRowBackground(AppColors.creamyWhite)
                    .foregroundColor(AppColors.black)
                }
            }
        }
        .navigationTitle("Availability")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, .light)
    }

    private func bindingForSlot(_ slot: String) -> Binding<Bool> {
        Binding<Bool>(
            get: { storageManager.dailyAvailability[slot] ?? true },
            set: { newValue in
                storageManager.dailyAvailability[slot] = newValue
            }
        )
    }
}

struct AvailabilityView_Previews: PreviewProvider {
    static var previews: some View {
        let storage = StorageManager()
        AvailabilityView()
            .environmentObject(storage)
    }
}

