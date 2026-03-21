import SwiftUI

struct RecipeDetailView: View {
    let card: FamilyRecipeCard
    var requestDraft: RequestDraft
    @Binding var selectedTab: Int
    var onDelete: (() -> Void)?
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: Author + Status
                HStack(spacing: 8) {
                    if !card.authorName.isEmpty {
                        Text("от \(card.authorName)")
                            .font(.caption.weight(.semibold))
                            .textCase(.uppercase)
                            .tracking(0.8)
                            .foregroundStyle(Color.WP.textSecondary)
                    }

                    Text(card.statusLabel)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(card.statusColor.opacity(0.12))
                        .foregroundStyle(card.statusColor)
                        .clipShape(RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous))
                }
                .padding(.bottom, 16)

                // MARK: Recipe Story
                if let story = card.recipeStory, !story.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "book.pages")
                                .font(.caption2.weight(.semibold))
                            Text("ИСТОРИЯ РЕЦЕПТА")
                                .font(.caption.weight(.bold))
                                .tracking(0.8)
                        }
                        .foregroundStyle(Color.WP.accentDark)

                        Text(story)
                            .font(.subheadline)
                            .foregroundStyle(Color.WP.textPrimary.opacity(0.85))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous)
                            .stroke(Color.WP.outlineVariant.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.bottom, 16)
                }

                // MARK: Recipe text
                if card.isReceived {
                    VStack(alignment: .leading, spacing: 0) {
                        if let text = card.originalText, !text.isEmpty {
                            Text(text)
                                .font(.body)
                                .foregroundStyle(Color.WP.textPrimary)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("Текст рецепта отсутствует.")
                                .font(.body)
                                .foregroundStyle(Color.WP.textSecondary)
                                .italic()
                        }
                    }
                    .wpSurface(padding: 20, radius: DS.panelRadius)
                } else {
                    // Pending card — no recipe text yet
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.title2)
                            .foregroundStyle(Color.WP.accent)
                        Text("Ожидаем ответ от \(card.authorName)…")
                            .font(.subheadline)
                            .foregroundStyle(Color.WP.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous))
                }

                // MARK: Clarification CTA
                if !card.authorName.isEmpty && card.isReceived {
                    Button {
                        requestDraft.recipientName = card.authorName
                        requestDraft.dishName = "Уточнение: \(card.title)"
                        requestDraft.parentRecipeId = card.recipeId
                        selectedTab = 1
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .font(.caption2)
                            Text("Попросить уточнить")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(Color.WP.greenDark)
                        .textCase(.uppercase)
                        .tracking(0.3)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 16)
                }

                // MARK: Note section (only for received cards)
                if let recipeId = card.recipeId {
                    Divider()
                        .overlay(Color.WP.divider)
                        .padding(.top, 18)
                        .padding(.bottom, 16)

                    NoteSection(recipeId: recipeId)
                }
            }
            .padding(20)
        }
        .wpBackground()
        .navigationTitle(card.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let shareText = shareText {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.WP.accentDark)
                    }
                }

                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.WP.red)
                }
            }
        }
        .confirmationDialog(
            "Удалить «\(card.title)»?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                onDelete?()
                dismiss()
            }
        } message: {
            Text("Карточка будет скрыта из вашего списка.")
        }
    }

    private var shareText: String? {
        guard card.isReceived,
              let text = card.originalText?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        if card.authorName.isEmpty {
            return "\(card.title)\n\n\(text)"
        }
        return "\(card.title)\nот \(card.authorName)\n\n\(text)"
    }
}

// MARK: - Note Section

private struct NoteSection: View {
    let recipeId: String
    @State private var text = ""
    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "square.and.pencil")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.WP.textSecondary)
                Text("МОЯ ЗАМЕТКА")
                    .font(.caption.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Color.WP.textSecondary)
            }

            if isEditing {
                TextEditor(text: $text)
                    .font(.body)
                    .foregroundStyle(Color.WP.textPrimary)
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .background(Color.WP.surface)
                    .focused($isFocused)

                HStack(spacing: 10) {
                    Button("Сохранить") {
                        NotesStore.shared.save(text: text, for: recipeId)
                        isEditing = false
                    }
                    .buttonStyle(WPPrimaryButton())
                    .frame(width: 130)

                    Button("Отмена") {
                        text = NotesStore.shared.note(for: recipeId)?.text ?? ""
                        isEditing = false
                    }
                    .buttonStyle(WPSecondaryButton())
                    .frame(width: 100)
                }
            } else if let note = NotesStore.shared.note(for: recipeId) {
                Text(note.text)
                    .font(.body)
                    .foregroundStyle(Color.WP.textPrimary.opacity(0.85))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.WP.surface)

                Button("Редактировать") {
                    text = note.text
                    isEditing = true
                    isFocused = true
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.WP.accentDark)
            } else {
                Button {
                    text = ""
                    isEditing = true
                    isFocused = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption2)
                        Text("Добавить заметку")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color.WP.accentDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .background(
                    RoundedRectangle(cornerRadius: DS.buttonRadius, style: .continuous)
                        .strokeBorder(Color.WP.divider, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous)
                .strokeBorder(Color.WP.divider, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
        )
        .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous))
        .onAppear {
            text = NotesStore.shared.note(for: recipeId)?.text ?? ""
        }
    }
}
