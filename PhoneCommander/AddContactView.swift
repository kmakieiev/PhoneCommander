import SwiftUI

struct AddContactView: View {
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
            TextField("Name", text: $name)
            TextField("Phone", text: $phone)
            
            ForEach(Array(dynamicFields.keys.sorted()), id: \.self) { key in
                HStack {
                    Text(key) // Display the key as text
                    TextField("Enter \(key)", text: Binding<String>(
                        get: {
                            self.dynamicFields[key] ?? ""
                        },
                        set: { newValue in
                            self.dynamicFields[key] = newValue
                        }
                    ))
                    Button(action: {
                        dynamicFields.removeValue(forKey: key)
                    }) {
                        Image(systemName: "minus.circle")
                    }
                }
            }
            
            HStack {
                Picker(selection: $selectedFieldTypeIndex, label: Text("Add Field")) {
                    ForEach(0..<dynamicFieldTypes.count, id: \.self) { index in
                        Text(dynamicFieldTypes[index])
                            .tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                if dynamicFieldTypes[selectedFieldTypeIndex] == "Custom" {
                    TextField("Field Name", text: $customFieldName)
                    TextField("Field Value", text: $customFieldValue)
                }
                
                Button(action: {
                    // Handle adding dynamic field based on selection
                    addCustomField()
                }) {
                    Label("Add Field", systemImage: "plus.circle")
                }
            }

            Button(action: {
                saveContact()
            }) {
                Text("Save")
            }
        }
        .padding()
        .onAppear {
            if let contact = contact {
                name = contact.data["name"] as? String ?? ""
                phone = contact.data["phone"] as? String ?? ""
                dynamicFields = contact.dynamicFields ?? [:]
            }
        }
    }

    private func addCustomField() {
        let fieldType = dynamicFieldTypes[selectedFieldTypeIndex]
        
        if fieldType == "Email" || fieldType == "Instagram" {
            let key = fieldType
            let value = ""
            dynamicFields[key] = value
        } else if fieldType == "Custom" {
            let fieldName = customFieldName.trimmingCharacters(in: .whitespacesAndNewlines)
            let fieldValue = customFieldValue.trimmingCharacters(in: .whitespacesAndNewlines)

            if !fieldName.isEmpty && !fieldValue.isEmpty {
                let key = generateUniqueKey(for: fieldName)
                dynamicFields[key] = fieldValue
                // Clear input fields after adding
                customFieldName = ""
                customFieldValue = ""
            } else {
                print("Field Name and Field Value must not be empty")
            }
        }
    }

    private func generateUniqueKey(for fieldName: String) -> String {
        var key = fieldName
        var index = 1
        while dynamicFields.keys.contains(key) {
            key = "\(fieldName) \(index)"
            index += 1
        }
        return key
    }

    private func saveContact() {
        var newContactData: [String: Any] = [            "name": name,            "phone": phone,            "dynamicFields": dynamicFields        ]

        if var contact = contact {
            newContactData["_id"] = contact.id
            contact.data = newContactData
            onSave(contact)
        } else {
            let newContact = Contact(id: UUID().uuidString, data: newContactData)
            onSave(newContact)
        }
    }
}
