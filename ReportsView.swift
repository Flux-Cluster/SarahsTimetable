import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var storageManager: StorageManager

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Reports & Statistics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.black)
                        .padding(.top, 20)
                        .padding(.horizontal)

                    Section(header: Text("Last 7 Days")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.black)
                        .padding(.horizontal)) {

                        Text("Lessons Taught: \(lessonsInLast(days: 7).count)")
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                    }

                    Section(header: Text("Last 30 Days")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.black)
                        .padding(.horizontal)) {

                        let last30 = lessonsInLast(days: 30)
                        Text("Lessons Taught: \(last30.count)")
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("Unique Students: \(uniqueStudents(in: last30))")
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        let noShows = last30.filter { $0.status == .noShow }.count
                        let cancelled = last30.filter { $0.status == .cancelled }.count
                        Text("No-Shows: \(noShows)")
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                        Text("Cancelled: \(cancelled)")
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                    }

                    Spacer().frame(height: 50)
                }
                .padding(.bottom, 20)
            }
        }
        .environment(\.colorScheme, .light)
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Get lessons in last X days
    private func lessonsInLast(days: Int) -> [Lesson] {
        let now = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -days, to: now) else {
            return []
        }
        return storageManager.lessons.filter { $0.date >= startDate && $0.date <= now }
    }

    // MARK: - Unique Students
    private func uniqueStudents(in lessons: [Lesson]) -> Int {
        // Since each Lesson now stores studentName directly,
        // we can just gather those names and count unique.
        let names = lessons.map { $0.studentName }
        return Set(names).count
    }
}

