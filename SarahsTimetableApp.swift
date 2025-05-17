import SwiftUI

@main
struct SarahsTimetableApp: App {
    @StateObject private var storageManager = StorageManager()

    var body: some Scene {
        WindowGroup {
            DashboardView() // Now we start with the DashboardView
                .environmentObject(storageManager)
        }
    }
}

