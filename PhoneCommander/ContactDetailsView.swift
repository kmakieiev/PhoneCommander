import SwiftUI

struct ContactDetailsView: View {
    @ObservedObject var contact: Contact
    
    // Define the fields that should always be displayed first
    let staticFields: [String] = ["name", "phone"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contact Details")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            // Display static fields first
            ForEach(staticFields, id: \.self) { key in
                if key != "_id" { // Exclude "_id" from being displayed
                    if let value = contact.data[key] as? String, !value.isEmpty {
                        ContactFieldRow(label: key.capitalized, value: value)
                    }
                }
            }
            
            // Display remaining fields in the order they appear in the data dictionary
            ForEach(contact.data.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                if key != "_id" { // Exclude "_id" from being displayed {
                    if !staticFields.contains(key), let stringValue = value as? String, !stringValue.isEmpty {
                        ContactFieldRow(label: key.capitalized, value: stringValue)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.black))
        .cornerRadius(10)
        .padding()
    }
}

struct ContactFieldRow: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .fontWeight(.bold)
            Text(value)
        }
    }
}

struct ContactDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactDetailsView(contact: Contact(id: "1", data: ["name": "Kyryl Makieiev", "phone": "123 456 789", "Email": "kyryl.makieiev@gmail.com", "Instagram": "kmakieiev"]))
    }
}
