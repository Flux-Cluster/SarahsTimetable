import SwiftUI

struct StudentListView: View {
    @EnvironmentObject var storageManager: StorageManager

    @State private var searchText = ""
    @State private var showingAddStudentSheet = false

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            VStack {
                TextField("Search by student name...", text: $searchText)
                    .padding(10)
                    .background(AppColors.creamyWhite)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .font(.body)
                    .foregroundColor(AppColors.tyreRubber)

                List {
                    ForEach(filteredStudents) { student in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(student.studentFirstName) \(student.studentLastName)")
                                .font(.headline)
                                .foregroundColor(AppColors.tyreRubber)

                            if let pFirst = student.parentFirstName, let pLast = student.parentLastName {
                                Text("Parent: \(pFirst) \(pLast)")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.tyreRubber.opacity(0.8))
                            } else if let pFirst = student.parentFirstName {
                                Text("Parent: \(pFirst)")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.tyreRubber.opacity(0.8))
                            }

                            if let phone = student.mobile, !phone.isEmpty {
                                Text("Phone: \(phone)")
                                    .font(.footnote)
                                    .foregroundColor(AppColors.tyreRubber.opacity(0.7))
                            }
                            if let email = student.email, !email.isEmpty {
                                Text("Email: \(email)")
                                    .font(.footnote)
                                    .foregroundColor(AppColors.tyreRubber.opacity(0.7))
                            }
                        }
                        .padding(.vertical, 5)
                        .listRowBackground(AppColors.creamyWhite)
                    }
                    .onDelete(perform: deleteStudents)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Students")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .foregroundColor(AppColors.tyreRubber)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingAddStudentSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppColors.tyreRubber)
                }
            }
        }
        .sheet(isPresented: $showingAddStudentSheet) {
            AddStudentView()
                .environmentObject(storageManager)
        }
    }

    private var filteredStudents: [Student] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            return storageManager.students
        } else {
            return storageManager.students.filter { student in
                let fullName = "\(student.studentFirstName) \(student.studentLastName)".lowercased()
                return fullName.contains(q)
            }
        }
    }

    private func deleteStudents(at offsets: IndexSet) {
        storageManager.students.remove(atOffsets: offsets)
    }
}

