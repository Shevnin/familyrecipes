import SwiftUI

struct RecipesView: View {
    @State private var viewModel = RecipesViewModel()

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
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
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
            Text(recipe.title)
                .font(.headline)

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
