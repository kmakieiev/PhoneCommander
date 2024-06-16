import SwiftUI

struct ContentView: View {
    @State private var contacts: [Contact] = []
    @State private var currentContact: Contact? = nil
    @State private var isShowingAddContact = false
    @State private var isShowingEditContact = false
    @State private var isShowingDetails = false
    
    @State private var refreshInterval: TimeInterval = 5
    @State private var timer: Timer?
    
    let refreshIntervals: [TimeInterval] = [5, 10, 30, 60]
    @State private var sortAscending = true // Track sorting direction
    
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
            
            HStack {
                Button("Sort \(sortAscending ? "↓" : "↑")") {
                    sortContacts()
                    sortAscending.toggle()
                }
                .padding()
            }
            
            List(selection: $currentContact) {
                ForEach($contacts) { $contact in
                    Text(contact.name)
                        .tag(contact)
                        .contextMenu {
                            Button("Edit") {
                                isShowingEditContact = true
                                currentContact = contact
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
                    isShowingAddContact = true
                    currentContact = nil
                }
            }
            .padding()
        }
        .sheet(isPresented: $isShowingAddContact) {
            AddContactView(contact: $currentContact) { contact in
                saveNewContact(contact)
                isShowingAddContact = false
            }
        }
        .sheet(isPresented: $isShowingEditContact) {
            EditContactView(contact: $currentContact) { contact in
                updateContact(contact)
                isShowingEditContact = false
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
                        var fetchedContacts = jsonArray.map { dict in
                            Contact(id: dict["_id"] as? String ?? UUID().uuidString, data: dict)
                        }
                        
                        // Sort fetched contacts based on current sort order
                        if self.sortAscending {
                            fetchedContacts.sort(by: { $0.name < $1.name })
                        } else {
                            fetchedContacts.sort(by: { $0.name > $1.name })
                        }
                        
                        DispatchQueue.main.async {
                            self.contacts = fetchedContacts
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
            
            print("DELETE Request URL: \(url)")
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

    func saveNewContact(_ contact: Contact) {
        guard let url = URL(string: "http://localhost:3000/contacts") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: contact.data)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error saving contact: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("POST Request URL: \(url)")
                    print("Response status code: \(httpResponse.statusCode)")
                    if let responseData = data {
                        print("Response data: \(String(data: responseData, encoding: .utf8) ?? "No data")")
                    }
                }
                
                if let data = data {
                    do {
                        if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            let savedContact = Contact(id: jsonDict["_id"] as? String ?? UUID().uuidString, data: jsonDict)
                            DispatchQueue.main.async {
                                self.contacts.append(savedContact)
                            }
                        }
                    } catch {
                        print("Error parsing saved contact: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Error serializing contact data: \(error.localizedDescription)")
        }
    }

    func updateContact(_ contact: Contact) {
        guard let url = URL(string: "http://localhost:3000/contacts/\(contact.id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: contact.data)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error updating contact: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("PUT Request URL: \(url)")
                    print("Response status code: \(httpResponse.statusCode)")
                    if let responseData = data {
                        print("Response data: \(String(data: responseData, encoding: .utf8) ?? "No data")")
                    }
                }
                
                if let data = data {
                    do {
                        if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            let updatedContact = Contact(id: jsonDict["_id"] as? String ?? UUID().uuidString, data: jsonDict)
                            DispatchQueue.main.async {
                                if let index = self.contacts.firstIndex(where: { $0.id == contact.id }) {
                                    self.contacts[index] = updatedContact
                                }
                            }
                        }
                    } catch {
                        print("Error parsing updated contact: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Error serializing contact data: \(error.localizedDescription)")
        }
    }

    func saveRefreshInterval() {
        timer?.invalidate()
        startFetchingContacts()
    }
    
    func startFetchingContacts() {
        fetchContacts()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            fetchContacts()
        }
    }
    
    func sortContacts() {
        if sortAscending {
            contacts.sort(by: { $0.name < $1.name })
        } else {
            contacts.sort(by: { $0.name > $1.name })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
