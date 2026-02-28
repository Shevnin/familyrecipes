import SwiftUI

struct ContactEditView: View {
    @Environment(\.dismiss) private var dismiss
    let contact: Contact?

    @State private var name = ""
    @State private var type = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Имя") {
                    TextField("Бабушка Люда", text: $name)
                }
                Section("Кто это?") {
                    TextField("семья, друг, коллега…", text: $type)
                }
                Section("Заметка") {
                    TextField("Любит готовить борщ", text: $note)
                }
            }
            .navigationTitle(contact == nil ? "Новый контакт" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save(); dismiss() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let c = contact {
                    name = c.name
                    type = c.type
                    note = c.note
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if let c = contact {
            ContactsStore.shared.update(
                Contact(id: c.id, name: trimmed, type: type, note: note)
            )
        } else {
            ContactsStore.shared.add(
                Contact(name: trimmed, type: type, note: note)
            )
        }
    }
}
