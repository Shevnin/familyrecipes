import Foundation

actor SupabaseAuthClient {
    static let shared = SupabaseAuthClient()

    private let baseURL = AppConfig.supabaseURL
    private let anonKey = AppConfig.supabaseAnonKey

    private var currentSession: AuthTokenResponse?

    private init() {
        if let access = KeychainStore.read(.accessToken),
           let refresh = KeychainStore.read(.refreshToken) {
            self.currentSession = AuthTokenResponse(
                accessToken: access,
                refreshToken: refresh,
                expiresIn: 0,
                user: AuthUser(id: "", email: nil)
            )
        }
        // One-time migration: clear legacy UserDefaults tokens
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "fr_access_token") != nil {
            defaults.removeObject(forKey: "fr_access_token")
            defaults.removeObject(forKey: "fr_refresh_token")
        }
    }

    var accessToken: String? {
        currentSession?.accessToken
    }

    var isLoggedIn: Bool {
        currentSession?.accessToken != nil
    }

    func signIn(email: String, password: String) async throws -> AuthTokenResponse {
        let url = "\(baseURL)/auth/v1/token?grant_type=password"
        let body = ["email": email, "password": password]

        let response: AuthTokenResponse = try await HTTPClient.shared.request(
            url: url,
            method: .post,
            headers: ["apikey": anonKey],
            body: body
        )

        currentSession = response
        persistTokens(access: response.accessToken, refresh: response.refreshToken)
        return response
    }

    func refreshSession() async throws -> AuthTokenResponse {
        guard let refresh = currentSession?.refreshToken else {
            throw NetworkError.httpError(statusCode: 401, body: Data())
        }

        let url = "\(baseURL)/auth/v1/token?grant_type=refresh_token"
        let body = ["refresh_token": refresh]

        let response: AuthTokenResponse = try await HTTPClient.shared.request(
            url: url,
            method: .post,
            headers: ["apikey": anonKey],
            body: body
        )

        currentSession = response
        persistTokens(access: response.accessToken, refresh: response.refreshToken)
        return response
    }

    func signOut() {
        currentSession = nil
        KeychainStore.deleteAll()
    }

    private func persistTokens(access: String, refresh: String) {
        KeychainStore.save(access, for: .accessToken)
        KeychainStore.save(refresh, for: .refreshToken)
    }
}
