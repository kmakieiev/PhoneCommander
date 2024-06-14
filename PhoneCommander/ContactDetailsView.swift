import SwiftUI

struct ContactDetailsView: View {
    let contact: Contact

    var body: some View {
        VStack {
            Text("Name: \(contact.name)")
            if let phone = contact.phone {
                Text("Phone: \(phone)")
            }
            // Add more fields as needed
        }
        .padding()
        .frame(minWidth: 200, minHeight: 150)
    }
}
