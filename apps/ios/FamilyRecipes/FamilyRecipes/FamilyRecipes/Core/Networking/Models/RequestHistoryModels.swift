import SwiftUI

struct RecipeRequest: Decodable, Identifiable {
    let id: String
    let recipientName: String
    let dishName: String
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case recipientName = "recipient_name"
        case dishName = "dish_name"
        case status
        case createdAt = "created_at"
    }

    var statusLabel: String {
        switch status {
        case "pending": return "Ожидает"
        case "fulfilled": return "Получен"
        case "expired": return "Истёк"
        case "cancelled": return "Отменён"
        default: return status
        }
    }

    var statusColor: Color {
        switch status {
        case "pending": return .orange
        case "fulfilled": return .green
        case "expired": return .secondary
        case "cancelled": return .red
        default: return .secondary
        }
    }

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: createdAt) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: createdAt) else { return "" }
            return Self.displayFormatter.string(from: date)
        }
        return Self.displayFormatter.string(from: date)
    }

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}
