import Foundation

actor SupabaseAuthClient {
    static let shared = SupabaseAuthClient()

    private let baseURL = AppConfig.supabaseURL
    private let anonKey = AppConfig.supabaseAnonKey

    private var currentSession: AuthTokenResponse?

    private let defaults = UserDefaults.standard
    private let accessTokenKey = "fr_access_token"
    private let refreshTokenKey = "fr_refresh_token"

    private init() {
        // Restore tokens from previous session
        if let access = defaults.string(forKey: accessTokenKey),
           let refresh = defaults.string(forKey: refreshTokenKey) {
            self.currentSession = AuthTokenResponse(
                accessToken: access,
                refreshToken: refresh,
                expiresIn: 0,
                user: AuthUser(id: "", email: nil)
            )
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
            print("[AUTH-DEBUG] refreshSession: no refresh token stored")
            throw NetworkError.httpError(statusCode: 401, body: Data())
        }

        let oldAccess = currentSession?.accessToken ?? ""
        print("[AUTH-DEBUG] refreshSession start oldAccessMasked=\(oldAccess.prefix(12))")

        let url = "\(baseURL)/auth/v1/token?grant_type=refresh_token"
        let body = ["refresh_token": refresh]

        let response: AuthTokenResponse = try await HTTPClient.shared.request(
            url: url,
            method: .post,
            headers: ["apikey": anonKey],
            body: body
        )

        let changed = oldAccess.prefix(12) != response.accessToken.prefix(12)
        print("[AUTH-DEBUG] refreshSession done newAccessMasked=\(response.accessToken.prefix(12)) tokenChanged=\(changed)")

        currentSession = response
        persistTokens(access: response.accessToken, refresh: response.refreshToken)
        return response
    }

    func signOut() {
        currentSession = nil
        defaults.removeObject(forKey: accessTokenKey)
        defaults.removeObject(forKey: refreshTokenKey)
    }

    private func persistTokens(access: String, refresh: String) {
        defaults.set(access, forKey: accessTokenKey)
        defaults.set(refresh, forKey: refreshTokenKey)
    }
}
