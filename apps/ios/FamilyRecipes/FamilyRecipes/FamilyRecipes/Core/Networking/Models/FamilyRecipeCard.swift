import SwiftUI

struct FamilyRecipeCard: Decodable, Identifiable, Hashable {
    let cardId: String
    let householdId: String
    let title: String
    let authorName: String
    let originalText: String?
    let cardStatus: String
    let recipeStory: String?
    let recipeId: String?
    let requestId: String?
    let createdAt: String

    var id: String { cardId }

    enum CodingKeys: String, CodingKey {
        case cardId = "card_id"
        case householdId = "household_id"
        case title
        case authorName = "author_name"
        case originalText = "original_text"
        case cardStatus = "card_status"
        case recipeStory = "recipe_story"
        case recipeId = "recipe_id"
        case requestId = "request_id"
        case createdAt = "created_at"
    }

    var isReceived: Bool { cardStatus == "received" || cardStatus == "clarification" }
    var isPending: Bool { cardStatus == "pending" }

    var statusLabel: String {
        switch cardStatus {
        case "pending": return "Ожидает"
        case "received": return "Получен"
        case "clarification": return "Уточняется"
        case "expired": return "Истёк"
        default: return cardStatus
        }
    }

    var statusColor: Color {
        switch cardStatus {
        case "pending":        return Color.WP.accent
        case "received":       return Color.WP.green
        case "clarification":  return Color.WP.accent
        case "expired":        return Color.WP.textSecondary
        default:               return Color.WP.textSecondary
        }
    }
}
