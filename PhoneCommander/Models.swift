import Foundation

class Contact: ObservableObject, Identifiable, Hashable {
    var id: String
    @Published var data: [String: Any]

    init(id: String, data: [String: Any]) {
        self.id = id
        self.data = data
    }

    var name: String {
        data["name"] as? String ?? "No Name"
    }

    var phone: String? {
        data["phone"] as? String
    }

    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
