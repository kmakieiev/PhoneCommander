import Foundation

struct Contact: Identifiable, Hashable {
    var id: String
    var data: [String: Any]

    var name: String {
        data["name"] as? String ?? "No Name"
    }

    var phone: String? {
        data["phone"] as? String
    }
    
    var dynamicFields: [String: String]? {
        data["dynamicFields"] as? [String: String]
    }

    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
