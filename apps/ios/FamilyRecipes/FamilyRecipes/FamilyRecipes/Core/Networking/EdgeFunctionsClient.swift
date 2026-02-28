import Foundation

struct EdgeFunctionsClient {
    static let shared = EdgeFunctionsClient()
    private let functionsURL = AppConfig.functionsBaseURL
    private let restURL = AppConfig.supabaseURL + "/rest/v1"

    func createRequest(input: CreateRequestInput) async throws -> CreateRequestResponse {
        // Pre-flight: refresh token if expired or near-expiry (<60s)
        if let token = await SupabaseAuthClient.shared.accessToken, Self.isTokenExpired(token) {
            _ = try await SupabaseAuthClient.shared.refreshSession()
        }

        do {
            return try await performCreateRequest(input: input)
        } catch NetworkError.httpError(let code, _) where code == 401 {
            _ = try await SupabaseAuthClient.shared.refreshSession()
            return try await performCreateRequest(input: input)
        }
    }

    private func performCreateRequest(input: CreateRequestInput) async throws -> CreateRequestResponse {
        guard let token = await SupabaseAuthClient.shared.accessToken else {
            throw NetworkError.httpError(statusCode: 401, body: Data())
        }

        let url = "\(functionsURL)/create-request"
        return try await HTTPClient.shared.request(
            url: url,
            method: .post,
            headers: [
                "Authorization": "Bearer \(token)",
                "apikey": AppConfig.supabaseAnonKey
            ],
            body: input
        )
    }

    func fetchRecipes() async throws -> [Recipe] {
        if let token = await SupabaseAuthClient.shared.accessToken, Self.isTokenExpired(token) {
            _ = try await SupabaseAuthClient.shared.refreshSession()
        }

        do {
            return try await performFetchRecipes()
        } catch NetworkError.httpError(let code, _) where code == 401 {
            _ = try await SupabaseAuthClient.shared.refreshSession()
            return try await performFetchRecipes()
        }
    }

    private func performFetchRecipes() async throws -> [Recipe] {
        guard let token = await SupabaseAuthClient.shared.accessToken else {
            throw NetworkError.httpError(statusCode: 401, body: Data())
        }

        let url = "\(restURL)/recipes?select=id,title,author_name,original_text,created_at&order=created_at.desc"
        return try await HTTPClient.shared.request(
            url: url,
            method: .get,
            headers: [
                "Authorization": "Bearer \(token)",
                "apikey": AppConfig.supabaseAnonKey
            ]
        )
    }

    func ensureHousehold() async throws {
        guard let token = await SupabaseAuthClient.shared.accessToken else {
            throw NetworkError.httpError(statusCode: 401, body: Data())
        }

        let headers = [
            "Authorization": "Bearer \(token)",
            "apikey": AppConfig.supabaseAnonKey
        ]

        struct MemberRow: Decodable { let householdId: String
            enum CodingKeys: String, CodingKey { case householdId = "household_id" }
        }

        let members: [MemberRow] = try await HTTPClient.shared.request(
            url: "\(restURL)/household_members?select=household_id&limit=1",
            method: .get,
            headers: headers
        )

        guard members.isEmpty else { return }

        struct BootstrapInput: Encodable { let p_name: String }
        let _: String = try await HTTPClient.shared.request(
            url: "\(restURL)/rpc/create_household_with_owner",
            method: .post,
            headers: headers,
            body: BootstrapInput(p_name: "Моя семья")
        )
    }

    // MARK: - JWT Expiry Check

    private static func isTokenExpired(_ token: String) -> Bool {
        let parts = token.split(separator: ".")
        guard parts.count >= 2,
              let payloadData = base64URLDecode(String(parts[1])),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return true
        }
        return Date(timeIntervalSince1970: exp).timeIntervalSinceNow < 60
    }

    private static func base64URLDecode(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        return Data(base64Encoded: base64)
    }
}
