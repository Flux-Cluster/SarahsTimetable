import SwiftUI

struct AddOrEditTermSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storageManager: StorageManager

    let existingTermData: AcademicTermData?
    let onSave: (AcademicTermData) -> Void

    @State private var schoolName = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60 * 60 * 24 * 7 * 12)

    private let schools = ["Highsted", "Borden"] // optional

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text(existingTermData == nil ? "Add New Term" : "Edit Term")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.black)
                    .padding(.top, 20)

                Text("School Name")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                    .padding(.horizontal)

                Picker("School", selection: $schoolName) {
                    ForEach(schools, id: \.self) { s in
                        Text(s).tag(s)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .background(AppColors.creamyWhite)
                .cornerRadius(10)

                Text("Start Date")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                    .padding(.horizontal)

                DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(AppColors.creamyWhite)
                    .cornerRadius(10)
                    .padding(.horizontal)

                Text("End Date")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                    .padding(.horizontal)

                DatePicker("End", selection: $endDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(AppColors.creamyWhite)
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: {
                    let newTerm = AcademicTerm(schoolName: schoolName, startDate: startDate, endDate: endDate)
                    let termData = AcademicTermData(
                        id: existingTermData?.id ?? UUID(),
                        term: newTerm,
                        patternCycles: existingTermData?.patternCycles ?? []
                    )
                    onSave(termData)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.tyreRubber)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.black)
            }
        }
        .onAppear {
            if let existing = existingTermData {
                schoolName = existing.term.schoolName
                startDate  = existing.term.startDate
                endDate    = existing.term.endDate
            }
        }
    }
}

