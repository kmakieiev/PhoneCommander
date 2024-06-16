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
        VStack {
            HStack {
                Text("Name")
                TextField("Name", text: $name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            HStack {
                Text("Phone")
                TextField("Phone", text: $phone)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            ForEach(Array(dynamicFields.keys.sorted()), id: \.self) { key in
                HStack {
                    Text(key)
                    TextField(key, text: Binding<String>(
                        get: {
                            self.dynamicFields[key] ?? ""
                        },
                        set: { newValue in
                            self.dynamicFields[key] = newValue
                        }
                    ))
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        dynamicFields.removeValue(forKey: key)
                    }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
            }
            
            HStack {
                Picker(selection: $selectedFieldTypeIndex, label: Text("Add Field")) {
                    ForEach(0..<dynamicFieldTypes.count, id: \.self) { index in
                        Text(dynamicFieldTypes[index])
                            .tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                if dynamicFieldTypes[selectedFieldTypeIndex] == "Custom" {
                    TextField("Field Name", text: $customFieldName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Field Value", text: $customFieldValue)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {
                    addCustomField()
                }) {
                    Label("Add Field", systemImage: "plus.circle")
                        .padding()
                }
            }
            
            Button(action: {
                saveContact()
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
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
