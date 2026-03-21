import SwiftUI

@MainActor
@Observable
final class AppState {
    var isLoggedIn = false
    var isCheckingSession = true

    func checkSession() async {
        let hasToken = await SupabaseAuthClient.shared.isLoggedIn
        guard hasToken else {
            isCheckingSession = false
            return
        }

        do {
            _ = try await SupabaseAuthClient.shared.refreshSession()
            isLoggedIn = true
        } catch {
            // Refresh failed — token expired, require re-login
            await SupabaseAuthClient.shared.signOut()
            isLoggedIn = false
        }
        isCheckingSession = false
    }

    func didSignIn() {
        isLoggedIn = true
    }

    func signOut() async {
        await SupabaseAuthClient.shared.signOut()
        isLoggedIn = false
    }
}
