import SwiftUI

struct RecipeDetailView: View {
    let card: FamilyRecipeCard
    var requestDraft: RequestDraft
    @Binding var selectedTab: Int
    var onCardUpdated: ((FamilyRecipeCard) -> Void)?
    var onDelete: (() -> Void)?
    @State private var currentCard: FamilyRecipeCard
    @State private var showDeleteConfirm = false
    @State private var showPostCookSheet = false
    @State private var showClarificationCTA = false
    @Environment(\.dismiss) private var dismiss

    init(
        card: FamilyRecipeCard,
        requestDraft: RequestDraft,
        selectedTab: Binding<Int>,
        onCardUpdated: ((FamilyRecipeCard) -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.card = card
        self.requestDraft = requestDraft
        self._selectedTab = selectedTab
        self.onCardUpdated = onCardUpdated
        self.onDelete = onDelete
        self._currentCard = State(initialValue: card)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: Author + Status
                HStack(spacing: 8) {
                    if !currentCard.authorName.isEmpty {
                        Text("от \(currentCard.authorName)")
                            .font(.caption.weight(.semibold))
                            .textCase(.uppercase)
                            .tracking(0.8)
                            .foregroundStyle(Color.WP.textSecondary)
                    }

                    Text(currentCard.statusLabel)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(currentCard.statusColor.opacity(0.12))
                        .foregroundStyle(currentCard.statusColor)
                        .clipShape(RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous))
                }
                .padding(.bottom, 16)

                // MARK: Recipe Story
                if let story = currentCard.recipeStory, !story.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "book.pages")
                                .font(.caption2.weight(.semibold))
                            Text(currentCard.isTechnique ? "ИСТОРИЯ ТЕХНИКИ" : "ИСТОРИЯ РЕЦЕПТА")
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
                if currentCard.isReceived {
                    VStack(alignment: .leading, spacing: 0) {
                        if let text = currentCard.originalText, !text.isEmpty {
                            Text(text)
                                .font(.body)
                                .foregroundStyle(Color.WP.textPrimary)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text(currentCard.isTechnique ? "Описание техники отсутствует." : "Текст рецепта отсутствует.")
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
                        Text("Ожидаем ответ от \(currentCard.authorName)…")
                            .font(.subheadline)
                            .foregroundStyle(Color.WP.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous))
                }

                // MARK: Mastery Block (IOS-10) — only for received cards with a recipe_id
                if currentCard.isReceived, currentCard.recipeId != nil {
                    Divider()
                        .overlay(Color.WP.divider)
                        .padding(.top, 18)
                        .padding(.bottom, 16)

                    MasteryBlock(card: currentCard) {
                        showPostCookSheet = true
                    }
                }

                // MARK: Contextual clarification CTA (IOS-12) — after failed/partial attempt
                if showClarificationCTA, !currentCard.authorName.isEmpty, currentCard.isReceived {
                    Button {
                        requestDraft.recipientName = currentCard.authorName
                        requestDraft.dishName = "Уточнение: \(currentCard.title)"
                        requestDraft.parentRecipeId = currentCard.recipeId
                        requestDraft.contentKind = currentCard.contentKind
                        selectedTab = 1
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left")
                                .font(.caption)
                            Text("Уточнить у автора")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(Color.WP.greenDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.WP.green.opacity(0.08), in: RoundedRectangle(cornerRadius: DS.buttonRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.buttonRadius, style: .continuous)
                                .stroke(Color.WP.green.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                }

                // MARK: Baseline clarification CTA — always available for received cards
                if !currentCard.authorName.isEmpty && currentCard.isReceived {
                    Button {
                        requestDraft.recipientName = currentCard.authorName
                        requestDraft.dishName = "Уточнение: \(currentCard.title)"
                        requestDraft.parentRecipeId = currentCard.recipeId
                        requestDraft.contentKind = currentCard.contentKind
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
                    .padding(.top, showClarificationCTA ? 8 : 16)
                }

                // MARK: Note section (only for received cards)
                if let recipeId = currentCard.recipeId {
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
        .navigationTitle(currentCard.title)
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
        .sheet(isPresented: $showPostCookSheet) {
            PostCookSheet(card: currentCard) { response in
                // Update mastery state in place
                currentCard = currentCard.withMasteryUpdate(
                    cookCount: response.cookCount,
                    masteryStatusRaw: response.masteryStatus,
                    latestAttemptResult: response.latestAttemptResult,
                    latestAttemptNote: response.latestAttemptNote,
                    latestCookedAt: response.latestCookedAt
                )
                onCardUpdated?(currentCard)

                // IOS-12: show contextual clarification CTA after failed or partial attempt
                if response.latestAttemptResult == CookResult.failed.rawValue ||
                   response.latestAttemptResult == CookResult.partial.rawValue {
                    showClarificationCTA = true
                }
            }
        }
        .confirmationDialog(
            "Удалить «\(currentCard.title)»?",
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
        guard currentCard.isReceived,
              let text = currentCard.originalText?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        if currentCard.authorName.isEmpty {
            return "\(currentCard.title)\n\n\(text)"
        }
        return "\(currentCard.title)\nот \(currentCard.authorName)\n\n\(text)"
    }
}

// MARK: - Mastery Block (IOS-10)

private struct MasteryBlock: View {
    let card: FamilyRecipeCard
    var onLogCook: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row: label + mastery badge
            HStack(spacing: 6) {
                Image(systemName: "flame")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.WP.textSecondary)
                Text("МОЙ ПРОГРЕСС")
                    .font(.caption.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Color.WP.textSecondary)
                Spacer()
                // Mastery status badge
                HStack(spacing: 4) {
                    Image(systemName: card.masteryStatus.icon)
                        .font(.caption2.weight(.bold))
                    Text(card.masteryStatus.label)
                        .font(.caption2.weight(.bold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(card.masteryStatus.color.opacity(0.12))
                .foregroundStyle(card.masteryStatus.color)
                .clipShape(RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous))
            }

            // Cook count
            if card.cookCount > 0 {
                Text("\(card.isTechnique ? "Практиковал" : "Готовил"): \(card.cookCount) \(cookTimesLabel)")
                    .font(.subheadline)
                    .foregroundStyle(Color.WP.textPrimary)
            }

            // Latest post-cook note
            if let note = card.latestAttemptNote, !note.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ПОСЛЕДНЯЯ ЗАМЕТКА")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.6)
                        .foregroundStyle(Color.WP.textSecondary)
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(Color.WP.textPrimary.opacity(0.85))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // CTA
            Button(action: onLogCook) {
                HStack(spacing: 6) {
                    Image(systemName: card.isTechnique ? "dumbbell" : "fork.knife")
                        .font(.caption.weight(.semibold))
                    Text(card.isTechnique
                        ? (card.cookCount == 0 ? "Отметить первую практику" : "Отметить практику")
                        : (card.cookCount == 0 ? "Отметить первую готовку" : "Отметить готовку"))
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Color.WP.accentDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.WP.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: DS.buttonRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.buttonRadius, style: .continuous)
                        .stroke(Color.WP.accent.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous)
                .stroke(Color.WP.divider, lineWidth: 1)
        )
    }

    private var cookCountSuffix: String { "" }

    private var cookTimesLabel: String {
        switch card.cookCount % 10 {
        case 1 where card.cookCount % 100 != 11: return "раз"
        case 2, 3, 4 where !(11...14).contains(card.cookCount % 100): return "раза"
        default: return "раз"
        }
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
