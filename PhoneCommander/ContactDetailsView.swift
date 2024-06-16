import SwiftUI

struct ContactDetailsView: View {
    var contact: Contact
    
    var body: some View {
        VStack {
            Text("Name: \(contact.data["name"] as? String ?? "")")
            Text("Phone: \(contact.data["phone"] as? String ?? "")")
            
            if let dynamicFields = contact.dynamicFields {
                ForEach(Array(dynamicFields.keys.sorted()), id: \.self) { key in
                    Text("\(key): \(dynamicFields[key] ?? "")")
                }
            }
        }
        .padding()
    }
}
