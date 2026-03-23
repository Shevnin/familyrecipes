import Foundation

struct CreateRequestInput: Encodable {
    let recipientName: String
    let dishName: String
    var parentRecipeId: String?
    var contentKind: String

    enum CodingKeys: String, CodingKey {
        case recipientName = "recipient_name"
        case dishName = "dish_name"
        case parentRecipeId = "parent_recipe_id"
        case contentKind = "content_kind"
    }
}

struct CreateRequestResponse: Decodable {
    let requestId: String
    let token: String
    let webURL: String
    let shareText: String
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case token
        case webURL = "web_url"
        case shareText = "share_text"
        case expiresAt = "expires_at"
    }
}
