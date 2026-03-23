import SwiftUI

struct RecipesView: View {
    var requestDraft: RequestDraft
    @Binding var selectedTab: Int
    var viewModel: RecipesViewModel
    @State private var showingCreateSheet = false
    @State private var searchText = ""
    @State private var selectedKind = "recipe"

    private var filteredCards: [FamilyRecipeCard] {
        let byKind = viewModel.cards.filter { $0.contentKind == selectedKind }
        guard !searchText.isEmpty else { return byKind }
        let query = searchText.lowercased()
        return byKind.filter {
            $0.title.lowercased().contains(query) ||
            $0.authorName.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.cards.isEmpty {
                    ProgressView(selectedKind == "technique" ? "Загружаем техники…" : "Загружаем рецепты…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .wpBackground()
                } else if let error = viewModel.errorMessage {
                    WPFeedbackState(
                        icon: "exclamationmark.triangle",
                        title: "Ошибка",
                        message: error,
                        actionTitle: "Повторить"
                    ) {
                        Task { await viewModel.loadCards() }
                    }
                } else {
                    VStack(spacing: 0) {
                        // Segmented control — sticky above list
                        Picker("", selection: $selectedKind) {
                            Text("Рецепты").tag("recipe")
                            Text("Техники").tag("technique")
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, DS.screenPadding)
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                        Divider()
                            .overlay(Color.WP.divider)

                        if filteredCards.isEmpty && !viewModel.isLoading {
                            emptyStateForKind
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    searchField
                                        .padding(.horizontal, DS.screenPadding)
                                        .padding(.top, 8)
                                        .padding(.bottom, 10)

                                    Divider()
                                        .overlay(Color.WP.divider)

                                    ForEach(filteredCards) { card in
                                        NavigationLink(value: card) {
                                            cardRow(card)
                                        }
                                        .buttonStyle(.plain)

                                        Divider()
                                            .overlay(Color.WP.divider)
                                            .padding(.leading, DS.screenPadding)
                                    }
                                }
                            }
                            .wpBackground()
                            .refreshable {
                                await viewModel.loadCards()
                            }
                        }
                    }
                }
            }
            .navigationTitle(selectedKind == "technique" ? "Техники" : "Рецепты")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingCreateSheet = true } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.WP.accent)
                    }
                }
            }
            .navigationDestination(for: FamilyRecipeCard.self) { card in
                RecipeDetailView(
                    card: card,
                    requestDraft: requestDraft,
                    selectedTab: $selectedTab,
                    onCardUpdated: { updated in
                        viewModel.updateCard(updated)
                    },
                    onDelete: {
                        Task { await viewModel.hideCard(card) }
                    }
                )
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateRecipeView(contentKind: selectedKind) {
                    Task { await viewModel.loadCards() }
                }
            }
            .task {
                if viewModel.cards.isEmpty {
                    await viewModel.loadCards()
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateForKind: some View {
        let isTechnique = selectedKind == "technique"
        let hasOtherKind = viewModel.cards.contains { $0.contentKind != selectedKind }

        let message: String
        if viewModel.cards.isEmpty {
            message = "Здесь появятся рецепты и техники от близких людей.\nОтправьте запрос на вкладке «Запросить» или добавьте своё."
        } else if isTechnique {
            message = hasOtherKind
                ? "Техник пока нет.\nЗапросите технику у близкого человека или добавьте свою."
                : "Здесь появятся техники от близких людей.\nОтправьте запрос на вкладке «Запросить» или добавьте свою."
        } else {
            message = "Рецептов пока нет.\nЗапросите рецепт у близкого человека или добавьте свой."
        }

        return WPFeedbackState(
            icon: isTechnique ? "lightbulb" : "book.closed",
            title: "Пока пусто",
            message: message,
            actionTitle: "Добавить",
            action: { showingCreateSheet = true }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .wpBackground()
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.WP.textSecondary)

            TextField(
                selectedKind == "technique" ? "Поиск техник..." : "Поиск рецептов...",
                text: $searchText
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.subheadline)
            .foregroundStyle(Color.WP.textPrimary)
        }
        .padding(12)
        .background(Color.WP.surface, in: RoundedRectangle(cornerRadius: DS.inputRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.inputRadius, style: .continuous)
                .stroke(Color.WP.divider, lineWidth: 1)
        )
    }

    // MARK: - Card Row

    private func cardRow(_ card: FamilyRecipeCard) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(card.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.WP.textPrimary)
                        .multilineTextAlignment(.leading)

                    if let recipeId = card.recipeId,
                       NotesStore.shared.hasNote(for: recipeId) {
                        Circle()
                            .fill(Color.WP.green)
                            .frame(width: 6, height: 6)
                    }
                }

                HStack(spacing: 6) {
                    if !card.authorName.isEmpty {
                        Text(card.authorName)
                            .fontWeight(.medium)
                    }

                    Text(card.statusLabel)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(card.statusColor.opacity(0.12))
                        .foregroundStyle(card.statusColor)
                        .clipShape(RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous))

                    // Mastery badge (only for received cards with at least one attempt)
                    if card.isReceived && card.hasAttempts {
                        Image(systemName: card.masteryStatus.icon)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(card.masteryStatus.color)
                    }
                }
                .font(.caption)
                .foregroundStyle(Color.WP.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.WP.textSecondary.opacity(0.35))
                .padding(.top, 4)
        }
        .padding(.horizontal, DS.screenPadding)
        .padding(.vertical, DS.rowVerticalPadding)
        .contentShape(Rectangle())
    }
}
