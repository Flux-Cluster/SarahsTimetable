import SwiftUI

struct RecurringLessonView: View {
    @EnvironmentObject var storageManager: StorageManager

    var body: some View {
        ZStack {
            // Use the same gradient background as other screens
            AppGradient.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Recurring Lessons")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.black)
                    .padding(.top, 20)

                if storageManager.recurringPatterns.isEmpty {
                    Text("No recurring patterns yet.")
                        .font(.title3)
                        .foregroundColor(AppColors.black)
                        .padding()
                } else {
                    // Use a list with a custom background per row
                    List {
                        ForEach(storageManager.recurringPatterns) { pattern in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(pattern.studentName)
                                    .font(.headline)
                                    .foregroundColor(AppColors.black)
                                Text("\(weekdayName(pattern.weekday)) at \(timeString(pattern.hour, pattern.minute)) - \(pattern.location)")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.black.opacity(0.7))

                                if let notes = pattern.notes, !notes.isEmpty {
                                    Text("Notes: \(notes)")
                                        .font(.footnote)
                                        .foregroundColor(AppColors.black.opacity(0.7))
                                }
                            }
                            .padding(.vertical, 5)
                            .listRowBackground(AppColors.creamyWhite)
                        }
                        .onDelete(perform: deletePattern)
                    }
                    .listStyle(InsetGroupedListStyle())
                    // For iOS 16+, hide default background so the gradient shows
                    .scrollContentBackground(.hidden)
                }

                Spacer()
            }
        }
        // Force a light colour scheme if you want to avoid Dark Mode
        .environment(\.colorScheme, .light)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deletePattern(at offsets: IndexSet) {
        storageManager.recurringPatterns.remove(atOffsets: offsets)
    }

    private func weekdayName(_ weekday: Int) -> String {
        let formatter = DateFormatter()
        // Sunday=1, Monday=2, ... Saturday=7
        // If needed, shift logic for a Monday=1 scenario
        return formatter.weekdaySymbols[weekday - 1]
    }

    private func timeString(_ hour: Int, _ minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }
}

