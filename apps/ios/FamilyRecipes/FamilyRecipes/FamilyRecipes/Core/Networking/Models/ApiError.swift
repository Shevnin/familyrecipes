import Foundation

struct ApiErrorBody: Decodable {
    let error: String?
    let code: String?
    let message: String?

    var displayMessage: String {
        if let message, !message.isEmpty { return message }
        if let error, !error.isEmpty { return error }
        return "Произошла ошибка. Попробуйте ещё раз."
    }
}

extension NetworkError {
    var userMessage: String {
        switch self {
        case .httpError(let statusCode, let body):
            if let parsed = try? JSONDecoder().decode(ApiErrorBody.self, from: body) {
                return parsed.displayMessage
            }
            switch statusCode {
            case 401: return "Неверный email или пароль."
            case 403: return "Доступ запрещён."
            case 404: return "Не найдено."
            case 409: return "Запрос уже выполнен."
            case 410: return "Срок запроса истёк."
            default: return "Ошибка сервера (код \(statusCode))."
            }
        default:
            return errorDescription ?? "Неизвестная ошибка."
        }
    }
}
