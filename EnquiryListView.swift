import SwiftUI

struct EnquiryListView: View {
    @EnvironmentObject var storageManager: StorageManager

    var body: some View {
        NavigationView {
            List {
                ForEach(storageManager.enquiries.indices, id: \.self) { index in
                    NavigationLink(destination: EnquiryDetailView(enquiry: storageManager.enquiries[index])) {
                        VStack(alignment: .leading) {
                            Text(storageManager.enquiries[index].parentName)
                                .font(.headline)
                            Text("Student: \(storageManager.enquiries[index].studentName ?? "N/A")")
                                .font(.subheadline)
                            Text("Instrument: \(storageManager.enquiries[index].instrument ?? "N/A")")
                                .font(.subheadline)
                            Text("Contact: \(storageManager.enquiries[index].contactInfo ?? "None")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Notes: \(storageManager.enquiries[index].notes ?? "None")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    storageManager.enquiries.remove(atOffsets: offsets)
                }
            }
            .navigationTitle("Enquiries")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}

