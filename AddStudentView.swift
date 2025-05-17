import SwiftUI

struct AddStudentView: View {
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.presentationMode) var presentationMode

    // Basic fields for the new student & parent
    @State private var parentFirstName = ""
    @State private var parentLastName = ""
    @State private var studentFirstName = ""
    @State private var studentLastName = ""
    @State private var mobile = ""
    @State private var email = ""

    @State private var showingSuccessAlert = false

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Add Student")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.black)
                        .padding(.top, 20)
                        .padding(.horizontal)

                    sectionHeader("Parent/Guardian Details")
                    customTextField("Parent/Guardian First Name", text: $parentFirstName)
                    customTextField("Parent/Guardian Last Name", text: $parentLastName)

                    sectionHeader("Student Details")
                    customTextField("Student First Name", text: $studentFirstName)
                    customTextField("Student Last Name", text: $studentLastName)

                    sectionHeader("Contact Information")
                    customTextField("Mobile", text: $mobile, keyboardType: .phonePad)
                    customTextField("Email", text: $email, keyboardType: .emailAddress)

                    Button(action: saveStudent) {
                        Text("Save Student")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSave ? AppColors.tyreRubber : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(!canSave)

                    Spacer().frame(height: 50)
                }
                .padding(.bottom, 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.body)
                .foregroundColor(AppColors.black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, .light)
        .alert("Student Saved", isPresented: $showingSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("The student has been saved successfully.")
        }
    }

    private var canSave: Bool {
        let sFirst = studentFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let sLast  = studentLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        // must have at least the student's name
        return !(sFirst.isEmpty && sLast.isEmpty)
    }

    private func saveStudent() {
        let newStudent = Student(
            studentFirstName: studentFirstName,
            studentLastName: studentLastName,
            parentFirstName: parentFirstName.isEmpty ? nil : parentFirstName,
            parentLastName: parentLastName.isEmpty ? nil : parentLastName,
            mobile: mobile.isEmpty ? nil : mobile,
            email: email.isEmpty ? nil : email
        )

        storageManager.students.append(newStudent)
        showingSuccessAlert = true
    }

    // Reusable
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(AppColors.black)
            .padding(.horizontal)
    }

    private func customTextField(
        _ placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        TextField(placeholder, text: text)
            .font(.body)
            .padding()
            .keyboardType(keyboardType)
            .foregroundColor(AppColors.black)
            .background(AppColors.creamyWhite)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

