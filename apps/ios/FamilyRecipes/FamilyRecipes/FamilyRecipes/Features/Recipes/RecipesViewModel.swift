import SwiftUI

@MainActor
@Observable
final class RecipesViewModel {
    var cards: [FamilyRecipeCard] = []
    var isLoading = false
    var errorMessage: String?

    var isEmpty: Bool { cards.isEmpty && !isLoading && errorMessage == nil }

    func loadCards() async {
        isLoading = true
        errorMessage = nil

        do {
            cards = try await EdgeFunctionsClient.shared.fetchFamilyCards()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func hideCard(_ card: FamilyRecipeCard) async {
        do {
            try await EdgeFunctionsClient.shared.hideCard(card)
            cards.removeAll { $0.id == card.id }
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
