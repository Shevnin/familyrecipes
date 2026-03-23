import SwiftUI

// MARK: - Cook attempt result (mirrors DB check constraint)

enum CookResult: String, CaseIterable {
    case failed  = "failed"
    case partial = "partial"
    case success = "success"

    /// User-facing label for the result picker
    var label: String {
        switch self {
        case .failed:  return "Не получилось"
        case .partial: return "Почти получилось"
        case .success: return "Получается стабильно!"
        }
    }

    /// Icon for the result picker
    var icon: String {
        switch self {
        case .failed:  return "xmark.circle"
        case .partial: return "arrow.triangle.2.circlepath"
        case .success: return "checkmark.seal"
        }
    }
}

// MARK: - Mastery status (4 user-facing states, separate from card_status)

enum MasteryStatus: String {
    case received   = "получил"
    case tried      = "пробовал"
    case almostThere = "почти получилось"
    case mastered   = "замастерил"

    var label: String { rawValue }

    var color: Color {
        switch self {
        case .received:    return Color.WP.textSecondary
        case .tried:       return Color.WP.accent
        case .almostThere: return Color(hex: 0xD07800)
        case .mastered:    return Color.WP.green
        }
    }

    var icon: String {
        switch self {
        case .received:    return "tray.and.arrow.down"
        case .tried:       return "flame"
        case .almostThere: return "arrow.triangle.2.circlepath"
        case .mastered:    return "checkmark.seal.fill"
        }
    }

    init(raw: String?) {
        self = MasteryStatus(rawValue: raw ?? "") ?? .received
    }
}

// MARK: - FamilyRecipeCard

struct FamilyRecipeCard: Identifiable, Hashable {
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
    let contentKind: String

    // Mastery read-model fields (from recipe_attempts aggregation in VIEW)
    let cookCount: Int
    let masteryStatusRaw: String
    let latestAttemptResult: String?
    let latestAttemptNote: String?
    let latestCookedAt: String?

    var id: String { cardId }

    var isRecipe: Bool { contentKind == "recipe" }
    var isTechnique: Bool { contentKind == "technique" }

    var masteryStatus: MasteryStatus { MasteryStatus(raw: masteryStatusRaw) }
    var hasAttempts: Bool { cookCount > 0 }

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

    /// Creates a copy of this card with updated mastery fields after logging an attempt.
    func withMasteryUpdate(
        cookCount: Int,
        masteryStatusRaw: String,
        latestAttemptResult: String?,
        latestAttemptNote: String?,
        latestCookedAt: String?
    ) -> FamilyRecipeCard {
        FamilyRecipeCard(
            cardId: cardId,
            householdId: householdId,
            title: title,
            authorName: authorName,
            originalText: originalText,
            cardStatus: cardStatus,
            recipeStory: recipeStory,
            recipeId: recipeId,
            requestId: requestId,
            createdAt: createdAt,
            contentKind: contentKind,
            cookCount: cookCount,
            masteryStatusRaw: masteryStatusRaw,
            latestAttemptResult: latestAttemptResult,
            latestAttemptNote: latestAttemptNote,
            latestCookedAt: latestCookedAt
        )
    }
}

// MARK: - Decodable

extension FamilyRecipeCard: Decodable {
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
        case contentKind = "content_kind"
        case cookCount = "cook_count"
        case masteryStatusRaw = "mastery_status"
        case latestAttemptResult = "latest_attempt_result"
        case latestAttemptNote = "latest_attempt_note"
        case latestCookedAt = "latest_cooked_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        cardId = try c.decode(String.self, forKey: .cardId)
        householdId = try c.decode(String.self, forKey: .householdId)
        title = try c.decode(String.self, forKey: .title)
        authorName = try c.decode(String.self, forKey: .authorName)
        originalText = try c.decodeIfPresent(String.self, forKey: .originalText)
        cardStatus = try c.decode(String.self, forKey: .cardStatus)
        recipeStory = try c.decodeIfPresent(String.self, forKey: .recipeStory)
        recipeId = try c.decodeIfPresent(String.self, forKey: .recipeId)
        requestId = try c.decodeIfPresent(String.self, forKey: .requestId)
        createdAt = try c.decode(String.self, forKey: .createdAt)
        // Default to "recipe" for backwards compatibility before migration
        contentKind = try c.decodeIfPresent(String.self, forKey: .contentKind) ?? "recipe"
        cookCount = try c.decode(Int.self, forKey: .cookCount)
        masteryStatusRaw = try c.decode(String.self, forKey: .masteryStatusRaw)
        latestAttemptResult = try c.decodeIfPresent(String.self, forKey: .latestAttemptResult)
        latestAttemptNote = try c.decodeIfPresent(String.self, forKey: .latestAttemptNote)
        latestCookedAt = try c.decodeIfPresent(String.self, forKey: .latestCookedAt)
    }
}
