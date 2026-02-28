import SwiftUI

@MainActor
@Observable
final class RequestDraft {
    var recipientName: String?
    var dishName: String?

    var hasDraft: Bool {
        recipientName != nil || dishName != nil
    }

    func consume() -> (recipient: String, dish: String) {
        let result = (recipientName ?? "", dishName ?? "")
        recipientName = nil
        dishName = nil
        return result
    }
}
