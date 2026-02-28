import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: LocalizedError {
    case invalidURL
    case httpError(statusCode: Int, body: Data)
    case decodingError(Error)
    case noData
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL запроса."
        case .httpError(let code, _):
            return "Ошибка сервера (код \(code))."
        case .decodingError:
            return "Ошибка обработки ответа."
        case .noData:
            return "Сервер не вернул данные."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

struct HTTPClient {
    static let shared = HTTPClient()
    private let session = URLSession.shared
    private let decoder = JSONDecoder()

    func request<T: Decodable>(
        url: String,
        method: HTTPMethod = .post,
        headers: [String: String] = [:],
        body: (any Encodable)? = nil
    ) async throws -> T {
        guard let requestURL = URL(string: url) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, body: data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    func requestNoContent(
        url: String,
        method: HTTPMethod = .post,
        headers: [String: String] = [:],
        body: (any Encodable)? = nil
    ) async throws {
        guard let requestURL = URL(string: url) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, body: data)
        }
    }
}
