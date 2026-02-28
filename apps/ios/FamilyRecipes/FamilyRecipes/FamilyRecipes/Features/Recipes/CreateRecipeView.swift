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
            Form {
                Section("Название") {
                    TextField("Борщ, пирожки…", text: $title)
                }
                Section("Рецепт") {
                    TextEditor(text: $originalText)
                        .frame(minHeight: 150)
                }
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
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
