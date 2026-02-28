import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

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
            }
            .padding()
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.large)
    }
}
