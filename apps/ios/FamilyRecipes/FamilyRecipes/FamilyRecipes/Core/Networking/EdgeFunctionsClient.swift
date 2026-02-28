import Foundation

struct EdgeFunctionsClient {
    static let shared = EdgeFunctionsClient()
    private let functionsURL = AppConfig.functionsBaseURL
    private let restURL = AppConfig.supabaseURL + "/rest/v1"

    func createRequest(input: CreateRequestInput) async throws -> CreateRequestResponse {
        do {
            return try await performCreateRequest(input: input)
        } catch NetworkError.httpError(statusCode: 401, _) {
            // Token expired — refresh and retry once
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

    func ensureHousehold() async throws {
        guard let token = await SupabaseAuthClient.shared.accessToken else {
            throw NetworkError.httpError(statusCode: 401, body: Data())
        }

        // Check if user already has a household
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

        // Bootstrap: create household
        struct BootstrapInput: Encodable { let p_name: String }
        let _: String = try await HTTPClient.shared.request(
            url: "\(restURL)/rpc/create_household_with_owner",
            method: .post,
            headers: headers,
            body: BootstrapInput(p_name: "Моя семья")
        )
    }
}
