import SwiftUI

struct TermOverviewView: View {
    @EnvironmentObject var storageManager: StorageManager

    // For “add new term” or “edit existing term”
    @State private var showingAddTermSheet = false
    @State private var editingTermData: AcademicTermData? = nil

    // global summary range
    @State private var globalStartDate = Date()
    @State private var globalEndDate = Date().addingTimeInterval(60 * 60 * 24 * 7 * 12)

    // “All”, “Highsted”, or “Borden”
    private let schoolFilters = ["All", "Highsted", "Borden"]
    @State private var selectedFilter = "All"

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Term Overview & Management")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.black)
                    .padding(.top, 20)

                // School Filter
                Text("Filter by School")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(schoolFilters, id: \.self) { filter in
                        Text(filter).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .background(AppColors.creamyWhite)
                .cornerRadius(10)

                // “Global Summary” form
                Form {
                    Section(header: Text("Global Summary").foregroundColor(AppColors.black)) {
                        DatePicker("Global Start Date", selection: $globalStartDate, displayedComponents: .date)
                            .foregroundColor(AppColors.black)
                        DatePicker("Global End Date", selection: $globalEndDate, displayedComponents: .date)
                            .foregroundColor(AppColors.black)

                        Text("Total Lessons: \(calculateTotalLessonsInRange())")
                            .foregroundColor(AppColors.black)

                        // Now counting unique studentName instead of studentID
                        let uniqueNames = Set(storageManager.lessons.map { $0.studentName })
                        Text("Total Students: \(uniqueNames.count)")
                            .foregroundColor(AppColors.black)
                    }
                    .listRowBackground(AppColors.creamyWhite)
                    .scrollContentBackground(.hidden)
                }
                .listStyle(InsetGroupedListStyle())
                .frame(height: 280)

                // Filtered Terms list
                let filteredTerms = storageManager.terms.filter { termData in
                    if selectedFilter == "All" {
                        return true
                    }
                    return termData.term.schoolName == selectedFilter
                }

                if filteredTerms.isEmpty {
                    Text("No terms found for \(selectedFilter).")
                        .font(.title3)
                        .foregroundColor(AppColors.black)
                } else {
                    List {
                        ForEach(filteredTerms) { termData in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(termData.term.schoolName)
                                    .font(.headline)
                                    .foregroundColor(AppColors.tyreRubber)

                                Text("\(formattedDate(termData.term.startDate)) – \(formattedDate(termData.term.endDate))")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.tyreRubber.opacity(0.7))
                            }
                            .padding(.vertical, 5)
                            .listRowBackground(AppColors.creamyWhite)
                            .onTapGesture {
                                editingTermData = termData
                            }
                        }
                        .onDelete { offsets in
                            for offset in offsets {
                                let termID = filteredTerms[offset].id
                                storageManager.deleteTerm(by: termID)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                }

                Spacer()
            }
        }
        // Sheets
        .sheet(item: $editingTermData) { termToEdit in
            AddOrEditTermSheet(
                existingTermData: termToEdit,
                onSave: { updatedData in
                    storageManager.updateTerm(updatedData)
                }
            )
            .environmentObject(storageManager)
        }
        .sheet(isPresented: $showingAddTermSheet) {
            AddOrEditTermSheet(
                existingTermData: nil,
                onSave: { newTermData in
                    storageManager.addTerm(newTermData)
                }
            )
            .environmentObject(storageManager)
        }
        // Plus button
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            showingAddTermSheet = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(AppColors.tyreRubber)
        })
    }

    private func calculateTotalLessonsInRange() -> Int {
        let filtered = storageManager.lessons.filter {
            $0.date >= globalStartDate && $0.date <= globalEndDate
        }
        return filtered.count
    }

    private func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
}

extension Array where Element: Hashable {
    var uniqueCount: Int {
        Set(self).count
    }
}

