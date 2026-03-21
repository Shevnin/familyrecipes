import SwiftUI

@MainActor
@Observable
final class CreateRequestViewModel {
    var recipientName = ""
    var dishName = ""
    var parentRecipeId: String?
    var isLoading = false
    var errorMessage: String?
    var result: CreateRequestResponse?

    // Share (for history re-share)
    var showShareSheet = false
    var activeShareText: String?

    var isFormValid: Bool {
        !recipientName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !dishName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Contacts from store (history names now come from shared cardsViewModel)
    func contactSuggestions(from cards: [FamilyRecipeCard]) -> [String] {
        var seen = Set<String>()
        var names: [String] = []
        for c in ContactsStore.shared.contacts {
            let lower = c.name.lowercased()
            if seen.insert(lower).inserted { names.append(c.name) }
        }
        for card in cards where card.requestId != nil {
            let lower = card.authorName.lowercased()
            if seen.insert(lower).inserted { names.append(card.authorName) }
        }
        return names
    }

    /// Filtered suggestions matching current input
    func filteredSuggestions(from cards: [FamilyRecipeCard]) -> [String] {
        let query = recipientName.trimmingCharacters(in: .whitespaces).lowercased()
        let all = contactSuggestions(from: cards)
        guard !query.isEmpty else { return all }
        return all.filter { $0.lowercased().contains(query) }
    }

    func createRequest() async {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        let input = CreateRequestInput(
            recipientName: recipientName.trimmingCharacters(in: .whitespaces),
            dishName: dishName.trimmingCharacters(in: .whitespaces),
            parentRecipeId: parentRecipeId
        )

        do {
            let response = try await EdgeFunctionsClient.shared.createRequest(input: input)
            result = response

            // Cache link for history re-share
            LinkCacheStore.shared.store(
                requestId: response.requestId,
                webURL: response.webURL,
                shareText: response.shareText
            )

            // Auto-save recipient as contact if not already saved
            let trimmedName = recipientName.trimmingCharacters(in: .whitespaces)
            let exists = ContactsStore.shared.contacts.contains {
                $0.name.lowercased() == trimmedName.lowercased()
            }
            if !exists && !trimmedName.isEmpty {
                ContactsStore.shared.add(Contact(name: trimmedName))
            }
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func reset() {
        recipientName = ""
        dishName = ""
        parentRecipeId = nil
        result = nil
        errorMessage = nil
    }

    func canShareCard(_ card: FamilyRecipeCard) -> Bool {
        guard let requestId = card.requestId else { return false }
        return LinkCacheStore.shared.entry(for: requestId) != nil
    }

    func shareCard(_ card: FamilyRecipeCard) {
        guard let requestId = card.requestId,
              let entry = LinkCacheStore.shared.entry(for: requestId) else { return }
        activeShareText = entry.shareText
        showShareSheet = true
    }
}
