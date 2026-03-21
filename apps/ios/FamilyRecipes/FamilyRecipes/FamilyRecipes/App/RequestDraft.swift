import SwiftUI

@MainActor
@Observable
final class RequestDraft {
    var recipientName: String?
    var dishName: String?
    var parentRecipeId: String?

    var hasDraft: Bool {
        recipientName != nil || dishName != nil
    }

    func consume() -> (recipient: String, dish: String, parentRecipeId: String?) {
        let result = (recipientName ?? "", dishName ?? "", parentRecipeId)
        recipientName = nil
        dishName = nil
        parentRecipeId = nil
        return result
    }
}
