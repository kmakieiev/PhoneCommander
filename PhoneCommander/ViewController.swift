import Cocoa

class ViewController: NSViewController {

    let tableView = NSTableView()
    var contacts: [[String: Any]] = []

    override func loadView() {
        view = NSView()

        setupTableView()
        setupButtons()
        fetchContacts()
    }

    func setupTableView() {
        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        tableView.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Contact")))
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])

        tableView.delegate = self
        tableView.dataSource = self
    }

    func setupButtons() {
        let addButton = NSButton(title: "Add", target: self, action: #selector(addContact))
        let editButton = NSButton(title: "Edit", target: self, action: #selector(editContact))
        let deleteButton = NSButton(title: "Delete", target: self, action: #selector(deleteContact))

        let stackView = NSStackView(views: [addButton, editButton, deleteButton])
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func fetchContacts() {
        guard let url = URL(string: "http://localhost:3000/contacts") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        self.contacts = jsonArray
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    print("Error fetching contacts: \(error)")
                }
            }
        }
        task.resume()
    }

    @objc func addContact() {
        let addContactVC = AddContactViewController()
        addContactVC.delegate = self
        presentAsModalWindow(addContactVC)
    }

    @objc func editContact() {
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            let contact = contacts[selectedRow]
            let addContactVC = AddContactViewController()
            addContactVC.contact = contact
            addContactVC.isEditingContact = true
            addContactVC.delegate = self
            presentAsModalWindow(addContactVC)
        }
    }

    @objc func deleteContact() {
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            let contact = contacts[selectedRow]
            guard let id = contact["_id"] as? String else {
                print("Contact ID not found")
                return
            }
            guard let url = URL(string: "http://localhost:3000/contacts/\(id)") else {
                print("Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error deleting contact: \(error)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("No HTTP response")
                    return
                }
                print("HTTP response status code:", httpResponse.statusCode)
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Response data:", json)
                        }
                    } catch {
                        print("Error parsing JSON:", error)
                    }
                } else {
                    print("No response data")
                }
                DispatchQueue.main.async {
                    self.fetchContacts()
                }
            }
            task.resume()
        } else {
            print("No row selected")
        }
    }
}

extension ViewController: AddContactDelegate {
    func didAddContact(_ contact: [String: Any]) {
        guard let url = URL(string: "http://localhost:3000/contacts") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: contact, options: [])
        } catch {
            print("Error serializing JSON:", error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error adding contact:", error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No valid HTTP response")
                return
            }
            print("HTTP response status code:", httpResponse.statusCode)
            if let data = data {
                do {
                    if let newContact = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.contacts.append(newContact)
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    print("Error parsing JSON response:", error)
                }
            } else {
                print("No data received")
            }
        }
        task.resume()
    }

    func didEditContact(_ contact: [String: Any]) {
        guard let id = contact["_id"] as? String else { return }
        guard let url = URL(string: "http://localhost:3000/contacts/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: contact, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let updatedContact = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            if let index = self.contacts.firstIndex(where: { ($0["_id"] as? String) == id }) {
                                self.contacts[index] = updatedContact
                                self.tableView.reloadData()
                            }
                        }
                    }
                } catch {
                    print("Error editing contact: \(error)")
                }
            }
        }
        task.resume()
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ContactCell")
        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            let contact = contacts[row]
            cell.textField?.stringValue = contact["name"] as? String ?? "No Name"
            return cell
        } else {
            let cell = NSTableCellView()
            cell.identifier = cellIdentifier
            let textField = NSTextField()
            textField.isBordered = false
            textField.drawsBackground = false
            cell.addSubview(textField)
            cell.textField = textField
            return cell
        }
    }
}
