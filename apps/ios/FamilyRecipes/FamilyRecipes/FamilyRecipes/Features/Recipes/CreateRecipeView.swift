import SwiftUI

struct CreateRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var originalText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var onSaved: () -> Void

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !originalText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Название")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.WP.textSecondary)
                        TextField("Борщ, пирожки…", text: $title)
                            .wpInput()
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Рецепт")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.WP.textSecondary)
                        TextEditor(text: $originalText)
                            .font(.body)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(
                                Color.WP.surfaceSoft,
                                in: RoundedRectangle(cornerRadius: DS.inputRadius, style: .continuous)
                            )
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(Color.WP.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
            }
            .wpBackground()
            .navigationTitle("Новый рецепт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Сохранить") {
                            Task { await save() }
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.WP.accent)
                        .disabled(!isValid)
                    }
                }
            }
        }
    }

    private func save() async {
        isLoading = true
        errorMessage = nil

        do {
            try await EdgeFunctionsClient.shared.createRecipe(
                title: title.trimmingCharacters(in: .whitespaces),
                originalText: originalText.trimmingCharacters(in: .whitespaces)
            )
            onSaved()
            dismiss()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
