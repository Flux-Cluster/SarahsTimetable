import Foundation
import Combine

struct AvailabilitySlot: Identifiable {
    let id = UUID()
    var hour: Int  // For example, 9 for 9:00 AM, 10 for 10:00 AM, etc.
    var isAvailable: Bool
}

class AvailabilityManager: ObservableObject {
    @Published var dailySlots: [AvailabilitySlot]

    init() {
        // Example: 9AM to 5PM (9 to 17)
        dailySlots = (9...17).map { hour in
            AvailabilitySlot(hour: hour, isAvailable: true)
        }
    }

    // In the future, we can add load/save methods or integrate with StorageManager.
}

