import SwiftUI

struct EditContactView: View {
    @Binding var contact: Contact?
    var onSave: (Contact) -> Void
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var dynamicFields: [String: String] = [:]
    
    let dynamicFieldTypes = ["Email", "Instagram", "Custom"]
    
    @State private var selectedFieldTypeIndex = 0 // Track selected field type index
    @State private var customFieldName: String = ""
    @State private var customFieldValue: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit Contact")
                .font(.title)
                .padding(.bottom, 10)
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Phone", text: $phone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            ForEach(Array(dynamicFields.keys.sorted()), id: \.self) { key in
                HStack(spacing: 10) {
                    Text(key)
                        .frame(width: 100, alignment: .leading)
                    
                    TextField("", text: Binding<String>(
                        get: {
                            self.dynamicFields[key] ?? ""
                        },
                        set: { newValue in
                            self.dynamicFields[key] = newValue
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        dynamicFields.removeValue(forKey: key)
                    }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.red)
                    }
                }
            }
            
            HStack(spacing: 10) {
                Picker(selection: $selectedFieldTypeIndex, label: Text("Add Field")) {
                    ForEach(0..<dynamicFieldTypes.count, id: \.self) { index in
                        Text(dynamicFieldTypes[index])
                            .tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
                
                if dynamicFieldTypes[selectedFieldTypeIndex] == "Custom" {
                    VStack(alignment: .leading, spacing: 5) {
                        TextField("Field Name", text: $customFieldName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Field Value", text: $customFieldValue)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .frame(width: 200)
                }
                
                Button(action: {
                    addCustomField()
                }) {
                    Label("Add Field", systemImage: "plus.circle")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            Spacer()
            
            Button(action: {
                saveContact()
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .padding()
        .onAppear {
            if let contact = contact {
                name = contact.data["name"] as? String ?? ""
                phone = contact.data["phone"] as? String ?? ""
                dynamicFields = contact.data.filter { $0.key != "name" && $0.key != "phone" && $0.key != "_id" }
                    .mapValues { $0 as? String ?? "" }
            }
        }
        .frame(width: 400, height: 350)
    }
    
    private func addCustomField() {
        let fieldType = dynamicFieldTypes[selectedFieldTypeIndex]
        
        if fieldType == "Email" || fieldType == "Instagram" {
            dynamicFields[fieldType] = ""
        } else if fieldType == "Custom" {
            let fieldName = customFieldName.trimmingCharacters(in: .whitespacesAndNewlines)
            let fieldValue = customFieldValue.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !fieldName.isEmpty && !fieldValue.isEmpty {
                dynamicFields[fieldName] = fieldValue
                customFieldName = ""
                customFieldValue = ""
            }
        }
    }
    
    private func saveContact() {
        var newContactData: [String: Any] = [
            "name": name,
            "phone": phone
        ]
        for (key, value) in dynamicFields {
            newContactData[key] = value
        }
        
        if var contact = contact {
            contact.data = newContactData
            onSave(contact)
        } else {
            let newContact = Contact(id: UUID().uuidString, data: newContactData)
            onSave(newContact)
        }
    }
}

struct EditContactView_Previews: PreviewProvider {
    static var previews: some View {
        EditContactView(contact: .constant(Contact(id: "1", data: ["name": "John Doe", "phone": "123-456-7890"])), onSave: { _ in })
    }
}
