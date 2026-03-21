import Foundation

struct CreateRequestInput: Encodable {
    let recipientName: String
    let dishName: String
    var recipeStory: String?
    var parentRecipeId: String?

    enum CodingKeys: String, CodingKey {
        case recipientName = "recipient_name"
        case dishName = "dish_name"
        case recipeStory = "recipe_story"
        case parentRecipeId = "parent_recipe_id"
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
