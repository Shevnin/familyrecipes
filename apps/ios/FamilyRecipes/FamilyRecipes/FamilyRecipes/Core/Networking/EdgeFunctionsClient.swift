import Foundation

struct EdgeFunctionsClient {
    static let shared = EdgeFunctionsClient()
    private let functionsURL = AppConfig.functionsBaseURL
    private let restURL = AppConfig.supabaseURL + "/rest/v1"

    func createRequest(input: CreateRequestInput) async throws -> CreateRequestResponse {
        // Pre-flight: ensure token is fresh before sending
        let preToken = await SupabaseAuthClient.shared.accessToken
        let preInfo = Self.jwtDebugInfo(preToken)
        print("[CR-DEBUG] pre-flight tokenExists=\(preInfo.exists) exp=\(preInfo.exp) isExpired=\(preInfo.isExpired) masked=\(preInfo.masked)")

        if preInfo.isExpired {
            print("[CR-DEBUG] token expired/near-expiry, refreshing before request")
            let oldMasked = preInfo.masked
            _ = try await SupabaseAuthClient.shared.refreshSession()
            let newToken = await SupabaseAuthClient.shared.accessToken
            let newMasked = String((newToken ?? "").prefix(12))
            print("[CR-DEBUG] refresh done oldMasked=\(oldMasked) newMasked=\(newMasked) changed=\(oldMasked != newMasked)")
        }

        do {
            return try await performCreateRequest(input: input)
        } catch NetworkError.httpError(let code, let body) where code == 401 {
            let bodyStr = String(data: body, encoding: .utf8) ?? "<non-utf8>"
            print("[CR-DEBUG] got 401, body=\(bodyStr). Refreshing and retrying…")
            let oldToken = await SupabaseAuthClient.shared.accessToken
            _ = try await SupabaseAuthClient.shared.refreshSession()
            let newToken = await SupabaseAuthClient.shared.accessToken
            print("[CR-DEBUG] retry refresh done changed=\(oldToken?.prefix(12) != newToken?.prefix(12))")
            return try await performCreateRequest(input: input)
        }
    }

    private func performCreateRequest(input: CreateRequestInput) async throws -> CreateRequestResponse {
        guard let token = await SupabaseAuthClient.shared.accessToken else {
            print("[CR-DEBUG] performCreateRequest: no access token")
            throw NetworkError.httpError(statusCode: 401, body: Data())
        }

        let info = Self.jwtDebugInfo(token)
        print("[CR-DEBUG] sending request masked=\(info.masked) exp=\(info.exp) isExpired=\(info.isExpired)")

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

    // MARK: - JWT Debug Helper

    private struct JWTDebugInfo {
        let exists: Bool
        let exp: String
        let isExpired: Bool
        let masked: String
    }

    private static func jwtDebugInfo(_ token: String?) -> JWTDebugInfo {
        guard let token, !token.isEmpty else {
            return JWTDebugInfo(exists: false, exp: "n/a", isExpired: true, masked: "nil")
        }

        let masked = String(token.prefix(12))
        let parts = token.split(separator: ".")
        guard parts.count >= 2,
              let payloadData = base64URLDecode(String(parts[1])),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let expValue = json["exp"] as? TimeInterval else {
            return JWTDebugInfo(exists: true, exp: "parse-error", isExpired: true, masked: masked)
        }

        let expDate = Date(timeIntervalSince1970: expValue)
        let remainingSec = expDate.timeIntervalSinceNow
        let expStr = "\(Int(expValue)) (in \(Int(remainingSec))s)"
        return JWTDebugInfo(exists: true, exp: expStr, isExpired: remainingSec < 60, masked: masked)
    }

    private static func base64URLDecode(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        return Data(base64Encoded: base64)
    }
}
