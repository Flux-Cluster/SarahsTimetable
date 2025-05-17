import SwiftUI

struct ContractManagerView: View {
    @State private var showingDocumentPicker = false
    @State private var uploadedContractURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Manage Contracts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                if let contractURL = uploadedContractURL {
                    Text("Uploaded Contract:")
                        .font(.headline)
                    Text(contractURL.lastPathComponent)
                        .foregroundColor(.secondary)
                        .padding()

                    Button(action: {
                        showShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                            Text("Share Contract")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showShareSheet) {
                        if let url = uploadedContractURL {
                            ActivityView(activityItems: [url])
                        }
                    }

                } else {
                    Text("No contract uploaded yet.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                }

                Button(action: {
                    showingDocumentPicker = true
                }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                            .font(.title2)
                        Text("Upload Contract")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                }
                .fileImporter(
                    isPresented: $showingDocumentPicker,
                    allowedContentTypes: [.pdf],
                    allowsMultipleSelection: false
                ) { result in
                    handleDocumentPickerResult(result)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Contracts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func handleDocumentPickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                uploadedContractURL = url
            }
        case .failure(let error):
            print("Error selecting document: \(error)")
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

