import SwiftUI

// MARK: - PostCookSheet (IOS-11)
// Lightweight post-cook flow: pick result + optional short note.
// Does NOT replace the existing personal note (NoteSection).

struct PostCookSheet: View {
    let card: FamilyRecipeCard
    var onSaved: ((EdgeFunctionsClient.CookAttemptResponse) -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var selectedResult: CookResult? = nil
    @State private var noteText = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Result picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("КАК ПРОШЛО?")
                            .font(.caption.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(Color.WP.textSecondary)

                        VStack(spacing: 8) {
                            ForEach(CookResult.allCases, id: \.rawValue) { result in
                                ResultRow(
                                    result: result,
                                    isSelected: selectedResult == result
                                ) {
                                    selectedResult = result
                                }
                            }
                        }
                    }

                    // MARK: Note field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("КОРОТКАЯ ЗАМЕТКА")
                            .font(.caption.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(Color.WP.textSecondary)

                        Text("Что запомнить на следующий раз? Что вышло, что нет, что изменить.")
                            .font(.caption)
                            .foregroundStyle(Color.WP.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        TextEditor(text: $noteText)
                            .font(.body)
                            .foregroundStyle(Color.WP.textPrimary)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: DS.inputRadius, style: .continuous))
                            .focused($isNoteFocused)
                    }

                    // MARK: Error
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.WP.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: Save CTA
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Сохранить")
                        }
                    }
                    .buttonStyle(WPPrimaryButton())
                    .disabled(selectedResult == nil || isSaving)
                }
                .padding(DS.screenPadding)
            }
            .wpBackground()
            .navigationTitle(card.isTechnique ? "Отметить практику" : "Отметить готовку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundStyle(Color.WP.accentDark)
                }
            }
        }
    }

    private func save() async {
        guard let result = selectedResult,
              let recipeId = card.recipeId else { return }

        isSaving = true
        errorMessage = nil

        do {
            let response = try await EdgeFunctionsClient.shared.logCookAttempt(
                recipeId: recipeId,
                result: result,
                noteText: noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : noteText
            )
            onSaved?(response)
            dismiss()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}

// MARK: - Result Row

private struct ResultRow: View {
    let result: CookResult
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : result.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.WP.green : Color.WP.textSecondary)
                    .frame(width: 24)

                Text(result.label)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.WP.textPrimary : Color.WP.textSecondary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                isSelected
                    ? Color.WP.green.opacity(0.08)
                    : Color.WP.surface,
                in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous)
                    .stroke(
                        isSelected ? Color.WP.green.opacity(0.4) : Color.WP.divider,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
