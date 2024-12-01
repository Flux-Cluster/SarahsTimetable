//
//  Sarah_s_TimetableApp.swift
//  Sarah's Timetable
//
//  Created by Terry Spencer-Hopkins on 01/12/2024.
//

import SwiftUI

@main
struct Sarah_s_TimetableApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
