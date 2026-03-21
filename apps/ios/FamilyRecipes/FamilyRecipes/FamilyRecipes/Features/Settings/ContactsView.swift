import SwiftUI

struct ContactsView: View {
    @State private var showingAddSheet = false
    private var store = ContactsStore.shared

    var body: some View {
        Group {
            if store.contacts.isEmpty {
                WPFeedbackState(
                    icon: "person.2",
                    title: "Пока пусто",
                    message: "Добавьте родных и друзей — они появятся как подсказки при запросе рецепта."
                )
            } else {
                List {
                    ForEach(store.contacts) { contact in
                        NavigationLink {
                            ContactEditView(contact: contact)
                        } label: {
                            contactRow(contact)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { indexSet in
                        for idx in indexSet {
                            store.delete(store.contacts[idx])
                        }
                    }
                }
                .listStyle(.plain)
                .wpList()
                .listRowSeparatorTint(Color.WP.divider)
            }
        }
        .navigationTitle("Семья и друзья")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddSheet = true } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.WP.accent)
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
                .fill(ChipView.stableColor(for: contact.name).opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(contact.name.prefix(1)).uppercased())
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(ChipView.stableColor(for: contact.name))
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(contact.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.WP.textPrimary)
                if !contact.type.isEmpty {
                    Text(contact.type)
                        .font(.caption)
                        .foregroundStyle(Color.WP.textSecondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
