import SwiftUI

struct RecipesView: View {
    var requestDraft: RequestDraft
    @Binding var selectedTab: Int
    var viewModel: RecipesViewModel
    @State private var showingCreateSheet = false
    @State private var searchText = ""

    private var filteredCards: [FamilyRecipeCard] {
        guard !searchText.isEmpty else { return viewModel.cards }
        let query = searchText.lowercased()
        return viewModel.cards.filter {
            $0.title.lowercased().contains(query) ||
            $0.authorName.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.cards.isEmpty {
                    ProgressView("Загружаем рецепты…")
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
                } else if viewModel.isEmpty {
                    WPFeedbackState(
                        icon: "book.closed",
                        title: "Пока пусто",
                        message: "Здесь появятся ваши семейные рецепты.\nОтправьте запрос на вкладке «Запросить» или добавьте свой рецепт."
                    )
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
            .navigationTitle("Рецепты")
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
                    onDelete: {
                        Task { await viewModel.hideCard(card) }
                    }
                )
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateRecipeView {
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

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.WP.textSecondary)

            TextField("Поиск рецептов...", text: $searchText)
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
