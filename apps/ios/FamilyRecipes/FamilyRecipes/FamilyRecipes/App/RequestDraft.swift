import SwiftUI

@MainActor
@Observable
final class RequestDraft {
    var recipientName: String?
    var dishName: String?
    var parentRecipeId: String?
    var contentKind: String = "recipe"

    var hasDraft: Bool {
        recipientName != nil || dishName != nil
    }

    func consume() -> (recipient: String, dish: String, parentRecipeId: String?, contentKind: String) {
        let result = (recipientName ?? "", dishName ?? "", parentRecipeId, contentKind)
        recipientName = nil
        dishName = nil
        parentRecipeId = nil
        contentKind = "recipe"
        return result
    }
}
