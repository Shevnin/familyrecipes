import SwiftUI

struct ContactsView: View {
    @State private var showingAddSheet = false
    private var store = ContactsStore.shared

    var body: some View {
        Group {
            if store.contacts.isEmpty {
                ContentUnavailableView {
                    Label("Пока пусто", systemImage: "person.2")
                } description: {
                    Text("Добавьте родных и друзей — они появятся как подсказки при запросе рецепта.")
                }
            } else {
                List {
                    ForEach(store.contacts) { contact in
                        NavigationLink {
                            ContactEditView(contact: contact)
                        } label: {
                            contactRow(contact)
                        }
                    }
                    .onDelete { indexSet in
                        for idx in indexSet {
                            store.delete(store.contacts[idx])
                        }
                    }
                }
            }
        }
        .navigationTitle("Семья и друзья")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            ContactEditView(contact: nil)
        }
    }

    private func contactRow(_ contact: Contact) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(ChipView.stableColor(for: contact.name).opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(contact.name.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundStyle(ChipView.stableColor(for: contact.name))
                )

            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.body)
                if !contact.type.isEmpty {
                    Text(contact.type)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
