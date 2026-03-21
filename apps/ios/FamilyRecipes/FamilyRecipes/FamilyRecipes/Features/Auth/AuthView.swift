import SwiftUI

struct AuthView: View {
    let appState: AppState
    @State private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    formSection
                    signInButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
            }
            .wpBackground()
            .navigationBarTitleDisplayMode(.inline)
            .onSubmit { handleSubmit() }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.WP.accent)

            Text("Семейные рецепты")
                .font(.title2.bold())
                .foregroundStyle(Color.WP.textPrimary)

            Text("Войдите, чтобы начать собирать рецепты")
                .font(.subheadline)
                .foregroundStyle(Color.WP.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var formSection: some View {
        VStack(spacing: 14) {
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .wpInput()

            SecureField("Пароль", text: $viewModel.password)
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .wpInput()

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.WP.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var signInButton: some View {
        Button {
            Task { await viewModel.signIn(appState: appState) }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Войти")
            }
        }
        .buttonStyle(WPPrimaryButton())
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }

    private func handleSubmit() {
        switch focusedField {
        case .email:
            focusedField = .password
        case .password:
            Task { await viewModel.signIn(appState: appState) }
        case nil:
            break
        }
    }
}
