import SwiftUI

struct ContentView: View {
    @State private var contacts: [Contact] = []
    @State private var currentContact: Contact? = nil
    @State private var isShowingAddContact = false
    @State private var isEditing = false
    @State private var isShowingDetails = false
    
    @State private var refreshInterval: TimeInterval = 5
    @State private var timer: Timer?
    
    let refreshIntervals: [TimeInterval] = [5, 10, 30, 60]
    
    var body: some View {
        VStack {
            HStack {
                Picker("Refresh Interval", selection: $refreshInterval) {
                    ForEach(refreshIntervals, id: \.self) { interval in
                        Text("\(Int(interval)) seconds").tag(interval)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Button("Save") {
                    saveRefreshInterval()
                }
            }
            .padding()
            
            List(selection: $currentContact) {
                ForEach($contacts) { $contact in
                    Text(contact.name)
                        .tag(contact)
                        .contextMenu {
                            Button("Edit") {
                                isEditing = true
                                isShowingAddContact = true
                            }
                            Button("Delete") {
                                deleteContact(contact: contact)
                            }
                            Button("Details") {
                                currentContact = contact
                                isShowingDetails = true
                            }
                        }
                }
                .onDelete(perform: deleteContact)
            }
            .frame(maxHeight: .infinity)
            
            HStack {
                Button("Add") {
                    isEditing = false
                    currentContact = nil
                    isShowingAddContact = true
                }
            }
            .padding()
        }
        .sheet(isPresented: $isShowingAddContact) {
            AddContactView(contact: $currentContact) { contact in
                if isEditing {
                    if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
                        contacts[index] = contact
                    }
                } else {
                    contacts.append(contact)
                }
                isShowingAddContact = false
                
                // Save the contact to the server
                saveContactToServer(contact)
            }
        }
        .sheet(isPresented: $isShowingDetails) {
            if let currentContact = currentContact {
                ContactDetailsView(contact: currentContact)
            }
        }
        .onAppear(perform: startFetchingContacts)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func fetchContacts() {
        guard let url = URL(string: "http://localhost:3000/contacts") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        DispatchQueue.main.async {
                            self.contacts = jsonArray.map { dict in
                                Contact(id: dict["_id"] as? String ?? UUID().uuidString, data: dict)
                            }
                        }
                    }
                } catch {
                    print("Error fetching contacts: \(error)")
                }
            }
        }
        task.resume()
    }
    
    func deleteContact(at offsets: IndexSet) {
        offsets.forEach { index in
            let contact = contacts[index]
            deleteContact(contact: contact)
        }
    }
    
    func deleteContact(contact: Contact) {
        guard let url = URL(string: "http://localhost:3000/contacts/\(contact.id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting contact: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                return
            }
            
            // Print request details
            print("DELETE Request URL: \(url)")
            
            // Print response details
            print("Response status code: \(httpResponse.statusCode)")
            if let responseData = data {
                print("Response data: \(String(data: responseData, encoding: .utf8) ?? "No data")")
            }
            
            switch httpResponse.statusCode {
            case 204:
                print("Contact deleted successfully")
                DispatchQueue.main.async {
                    if let index = self.contacts.firstIndex(where: { $0.id == contact.id }) {
                        self.contacts.remove(at: index)
                    }
                }
            case 404:
                print("Contact not found on server")
            default:
                print("Unexpected status code: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }


    func saveContactToServer(_ contact: Contact) {
        guard let url = URL(string: "http://localhost:3000/contacts") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Create an ordered dictionary-like structure
            var contactData = [String: Any]()
            contactData["name"] = contact.name
            contactData["phone"] = contact.phone
            
            // Include dynamic fields directly in the contact data
            for (key, value) in contact.data {
                if key != "dynamicFields" {
                    contactData[key] = value
                }
            }
            
            // Include dynamic fields from dynamicFields dictionary
            if let dynamicFields = contact.data["dynamicFields"] as? [String: String] {
                for (key, value) in dynamicFields {
                    contactData[key] = value
                }
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: contactData, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing contact data: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error saving contact to server: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 201 {
                    print("Contact saved successfully to server")
                } else {
                    print("Unexpected response: \(response.statusCode)")
                }
            }
        }
        task.resume()
    }
    
    func startFetchingContacts() {
        timer?.invalidate()
        fetchContacts()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            fetchContacts()
        }
    }
    
    func saveRefreshInterval() {
        startFetchingContacts()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
