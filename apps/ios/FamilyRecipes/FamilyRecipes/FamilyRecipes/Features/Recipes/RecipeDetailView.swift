import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    var requestDraft: RequestDraft
    @Binding var selectedTab: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Author & date
                HStack {
                    if !recipe.authorName.isEmpty {
                        Label(recipe.authorName, systemImage: "person")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(recipe.formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Recipe text
                if let text = recipe.originalText, !text.isEmpty {
                    Text(text)
                        .font(.body)
                } else {
                    Text("Текст рецепта отсутствует.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .italic()
                }

                // IOS-07: Попросить уточнить
                if !recipe.authorName.isEmpty {
                    Divider()

                    Button {
                        requestDraft.recipientName = recipe.authorName
                        requestDraft.dishName = "Уточнение: \(recipe.title)"
                        selectedTab = 1
                    } label: {
                        Label("Попросить уточнить", systemImage: "arrow.uturn.left.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                // IOS-05: Notes
                Divider()

                NoteSection(recipeId: recipe.id)
            }
            .padding()
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Note Section

private struct NoteSection: View {
    let recipeId: String
    @State private var text = ""
    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Моя заметка")
                .font(.headline)

            if isEditing {
                TextEditor(text: $text)
                    .frame(minHeight: 80)
                    .focused($isFocused)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary.opacity(0.3))
                    )

                HStack {
                    Button("Сохранить") {
                        NotesStore.shared.save(text: text, for: recipeId)
                        isEditing = false
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button("Отмена") {
                        text = NotesStore.shared.note(for: recipeId)?.text ?? ""
                        isEditing = false
                    }
                    .controlSize(.small)
                }
            } else if let note = NotesStore.shared.note(for: recipeId) {
                Text(note.text)
                    .font(.body)
                    .foregroundStyle(.secondary)

                Button("Редактировать") {
                    text = note.text
                    isEditing = true
                }
                .font(.caption)
            } else {
                Button("Добавить заметку") {
                    text = ""
                    isEditing = true
                }
                .font(.subheadline)
            }
        }
        .onAppear {
            text = NotesStore.shared.note(for: recipeId)?.text ?? ""
        }
    }
}
