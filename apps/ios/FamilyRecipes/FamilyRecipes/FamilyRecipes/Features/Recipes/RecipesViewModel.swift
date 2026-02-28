import SwiftUI

@MainActor
@Observable
final class RecipesViewModel {
    var recipes: [Recipe] = []
    var isLoading = false
    var errorMessage: String?

    var isEmpty: Bool { recipes.isEmpty && !isLoading && errorMessage == nil }

    func loadRecipes() async {
        isLoading = true
        errorMessage = nil

        do {
            recipes = try await EdgeFunctionsClient.shared.fetchRecipes()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
