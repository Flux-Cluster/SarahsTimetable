import SwiftUI

struct ManageTermsView: View {
    @EnvironmentObject var storageManager: StorageManager

    @State private var showingAddTermSheet = false
    @State private var editingTermData: AcademicTermData? = nil

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Text("Manage Terms")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.black)
                    .padding(.top, 20)

                if storageManager.terms.isEmpty {
                    Text("No academic terms added yet.")
                        .font(.title3)
                        .foregroundColor(AppColors.black)
                        .padding()
                } else {
                    List {
                        ForEach(storageManager.terms) { termData in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(termData.term.schoolName)
                                    .font(.headline)
                                    .foregroundColor(AppColors.tyreRubber)
                                Text("\(fmt(termData.term.startDate)) – \(fmt(termData.term.endDate))")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.tyreRubber.opacity(0.7))
                            }
                            .padding(.vertical, 5)
                            .listRowBackground(AppColors.creamyWhite)
                            .onTapGesture {
                                editingTermData = termData
                            }
                        }
                        .onDelete(perform: deleteTerm)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(InsetGroupedListStyle())
                }
                Spacer()
            }
        }
        // EDIT TERM SHEET
        .sheet(item: $editingTermData) { termToEdit in
            AddOrEditTermSheet(existingTermData: termToEdit) { updated in
                storageManager.updateTerm(updated)
            }
            .environmentObject(storageManager)
        }
        // ADD TERM SHEET
        .sheet(isPresented: $showingAddTermSheet) {
            AddOrEditTermSheet(existingTermData: nil) { newTerm in
                storageManager.addTerm(newTerm)
            }
            .environmentObject(storageManager)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            showingAddTermSheet = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(AppColors.tyreRubber)
        })
    }

    private func deleteTerm(at offsets: IndexSet) {
        for offset in offsets {
            let termID = storageManager.terms[offset].id
            storageManager.deleteTerm(by: termID)
        }
    }

    private func fmt(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: d)
    }
}

