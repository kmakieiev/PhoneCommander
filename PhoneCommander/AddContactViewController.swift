import Cocoa

protocol AddContactDelegate {
    func didAddContact(_ contact: [String: Any])
    func didEditContact(_ contact: [String: Any])
}

class AddContactViewController: NSViewController {

    var contact: [String: Any]?
    var delegate: AddContactDelegate?
    var isEditingContact = false

    let nameField = NSTextField()
    let phoneField = NSTextField()
    // Add more fields as needed

    override func loadView() {
        view = NSView()

        let stackView = NSStackView(views: [nameField, phoneField])
        stackView.orientation = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 200)
        ])

        nameField.placeholderString = "Name"
        phoneField.placeholderString = "Phone"

        if let contact = contact {
            nameField.stringValue = contact["name"] as? String ?? ""
            phoneField.stringValue = contact["phone"] as? String ?? ""
            // Populate other fields
        }

        let saveButton = NSButton(title: isEditingContact ? "Save" : "Add", target: self, action: #selector(saveContact))
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func saveContact() {
        var newContact: [String: Any] = [
            "name": nameField.stringValue,
            "phone": phoneField.stringValue
            // Add other fields
        ]

        if isEditingContact {
            newContact["_id"] = contact?["_id"]
            delegate?.didEditContact(newContact)
        } else {
            delegate?.didAddContact(newContact)
        }

        dismiss(self)
    }
}

