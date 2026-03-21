import SwiftUI

@MainActor
@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    func signIn(appState: AppState) async {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await SupabaseAuthClient.shared.signIn(
                email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                password: password
            )
            try? await EdgeFunctionsClient.shared.ensureHousehold()
            appState.didSignIn()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
