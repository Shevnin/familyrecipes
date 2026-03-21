import SwiftUI

struct ContactEditView: View {
    @Environment(\.dismiss) private var dismiss
    let contact: Contact?

    @State private var name = ""
    @State private var type = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    field("Имя", placeholder: "Бабушка Люда", text: $name)
                    field("Кто это?", placeholder: "семья, друг, коллега…", text: $type)
                    field("Заметка", placeholder: "Любит готовить борщ", text: $note)
                }
                .padding(20)
            }
            .wpBackground()
            .navigationTitle(contact == nil ? "Новый контакт" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save(); dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.WP.accent)
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

    private func field(_ label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.WP.textSecondary)
            TextField(placeholder, text: text)
                .wpInput()
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
