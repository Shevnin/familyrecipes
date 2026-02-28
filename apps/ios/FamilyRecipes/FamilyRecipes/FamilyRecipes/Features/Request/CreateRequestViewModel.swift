import SwiftUI

@MainActor
@Observable
final class CreateRequestViewModel {
    var recipientName = ""
    var dishName = ""
    var isLoading = false
    var errorMessage: String?
    var result: CreateRequestResponse?
    var showShareSheet = false

    // History
    var history: [RecipeRequest] = []
    var isHistoryLoading = false
    var historyError: String?

    // Active share text (from result or history)
    var activeShareText: String?

    var isFormValid: Bool {
        !recipientName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !dishName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var chipNames: [String] {
        var seen = Set<String>()
        var result: [String] = []
        for c in ContactsStore.shared.contacts {
            let lower = c.name.lowercased()
            if seen.insert(lower).inserted { result.append(c.name) }
        }
        for r in history {
            let lower = r.recipientName.lowercased()
            if seen.insert(lower).inserted { result.append(r.recipientName) }
        }
        return result
    }

    func createRequest() async {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        let input = CreateRequestInput(
            recipientName: recipientName.trimmingCharacters(in: .whitespaces),
            dishName: dishName.trimmingCharacters(in: .whitespaces)
        )

        do {
            let response = try await EdgeFunctionsClient.shared.createRequest(input: input)
            result = response
            activeShareText = response.shareText
            showShareSheet = true

            // Cache link for history re-share
            LinkCacheStore.shared.store(
                requestId: response.requestId,
                webURL: response.webURL,
                shareText: response.shareText
            )

            // Refresh history
            await loadHistory()
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
        result = nil
        errorMessage = nil
    }

    func loadHistory() async {
        isHistoryLoading = true
        historyError = nil

        do {
            history = try await EdgeFunctionsClient.shared.fetchRequestHistory()
        } catch let error as NetworkError {
            historyError = error.userMessage
        } catch {
            historyError = error.localizedDescription
        }

        isHistoryLoading = false
    }

    func canShareRequest(_ req: RecipeRequest) -> Bool {
        LinkCacheStore.shared.entry(for: req.id) != nil
    }

    func shareRequest(_ req: RecipeRequest) {
        guard let entry = LinkCacheStore.shared.entry(for: req.id) else { return }
        activeShareText = entry.shareText
        showShareSheet = true
    }
}
