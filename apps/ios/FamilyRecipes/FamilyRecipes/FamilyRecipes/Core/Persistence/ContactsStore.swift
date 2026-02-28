import Foundation

struct Contact: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var type: String
    var note: String

    init(id: UUID = UUID(), name: String, type: String = "", note: String = "") {
        self.id = id
        self.name = name
        self.type = type
        self.note = note
    }
}

@MainActor
@Observable
final class ContactsStore {
    static let shared = ContactsStore()
    private static let key = "fr_contacts"

    var contacts: [Contact] = []

    private init() {
        contacts = LocalStore.load([Contact].self, key: Self.key) ?? []
    }

    func add(_ contact: Contact) {
        contacts.append(contact)
        persist()
    }

    func update(_ contact: Contact) {
        guard let idx = contacts.firstIndex(where: { $0.id == contact.id }) else { return }
        contacts[idx] = contact
        persist()
    }

    func delete(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        persist()
    }

    private func persist() {
        LocalStore.save(contacts, key: Self.key)
    }
}
