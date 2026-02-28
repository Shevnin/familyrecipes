import SwiftUI

struct RecipesView: View {
    var requestDraft: RequestDraft
    @Binding var selectedTab: Int
    @State private var viewModel = RecipesViewModel()
    @State private var showingCreateSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.recipes.isEmpty {
                    ProgressView("Загружаем рецепты…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView {
                        Label("Ошибка", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Повторить") {
                            Task { await viewModel.loadRecipes() }
                        }
                    }
                } else if viewModel.isEmpty {
                    ContentUnavailableView {
                        Label("Пока пусто", systemImage: "book")
                    } description: {
                        Text("Здесь появятся рецепты, когда кто-то ответит на ваш запрос.\nОтправьте запрос на вкладке «Запросить».")
                    }
                } else {
                    List(viewModel.recipes) { recipe in
                        NavigationLink(value: recipe) {
                            recipeRow(recipe)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadRecipes()
                    }
                }
            }
            .navigationTitle("Рецепты")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingCreateSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(
                    recipe: recipe,
                    requestDraft: requestDraft,
                    selectedTab: $selectedTab
                )
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateRecipeView {
                    Task { await viewModel.loadRecipes() }
                }
            }
            .task {
                if viewModel.recipes.isEmpty {
                    await viewModel.loadRecipes()
                }
            }
        }
    }

    private func recipeRow(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(recipe.title)
                    .font(.headline)

                if NotesStore.shared.hasNote(for: recipe.id) {
                    Image(systemName: "note.text")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                if !recipe.authorName.isEmpty {
                    Text("от \(recipe.authorName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(recipe.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
