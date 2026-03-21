#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct CreateRequestView: View {
    var requestDraft: RequestDraft
    var cardsViewModel: RecipesViewModel
    @State private var viewModel = CreateRequestViewModel()
    @State private var showSuggestions = false
    @State private var linkCopied = false
    @FocusState private var recipientFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    formSection

                    RequestHistorySection(
                        cards: cardsViewModel.cards.filter { $0.requestId != nil },
                        isLoading: cardsViewModel.isLoading,
                        errorMessage: cardsViewModel.errorMessage,
                        onRetry: { await cardsViewModel.loadCards() },
                        onShare: { viewModel.shareCard($0) },
                        canShare: { viewModel.canShareCard($0) }
                    )
                    .id("history")
                }
                .padding(.horizontal, DS.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .wpBackground()
            .navigationTitle("Запросить рецепт")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let text = viewModel.activeShareText {
                    ShareSheet(text: text)
                }
            }
            .task {
                if cardsViewModel.cards.isEmpty {
                    await cardsViewModel.loadCards()
                }
            }
            .onChange(of: requestDraft.hasDraft) { _, hasDraft in
                if hasDraft {
                    let draft = requestDraft.consume()
                    viewModel.recipientName = draft.recipient
                    viewModel.dishName = draft.dish
                    viewModel.parentRecipeId = draft.parentRecipeId
                    viewModel.result = nil
                }
            }
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 16) {
            // Recipient field with dropdown
            VStack(alignment: .leading, spacing: 6) {
                Text("Кому отправить?")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.WP.textSecondary)

                recipientField
            }

            // Recipe name
            VStack(alignment: .leading, spacing: 6) {
                Text("Название рецепта")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.WP.textSecondary)
                TextField("Борщ, пирожки с мясом...", text: $viewModel.dishName)
                    .wpInput()
                    .disabled(viewModel.result != nil)
            }

            // Error
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.WP.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // CTA
            if viewModel.result == nil {
                Button {
                    Task {
                        await viewModel.createRequest()
                        if viewModel.result != nil {
                            await cardsViewModel.loadCards()
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Получить ссылку")
                    }
                }
                .buttonStyle(WPPrimaryButton())
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .padding(.top, 4)
            }

            // Inline result
            if let result = viewModel.result {
                inlineResult(result)
            }
        }
        .wpSoftSurface(padding: 16, radius: DS.panelRadius)
    }

    // MARK: - Recipient Field with Suggestions

    private var recipientField: some View {
        VStack(spacing: 0) {
            TextField("Имя (мама, бабушка Люда...)", text: $viewModel.recipientName)
                .textContentType(.name)
                .wpInput()
                .focused($recipientFocused)
                .disabled(viewModel.result != nil)
                .onChange(of: recipientFocused) { _, focused in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showSuggestions = focused
                    }
                }
                .onChange(of: viewModel.recipientName) { _, _ in
                    if recipientFocused {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showSuggestions = true
                        }
                    }
                }

            if showSuggestions && viewModel.result == nil {
                let suggestions = viewModel.filteredSuggestions(from: cardsViewModel.cards)
                if !suggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(suggestions.prefix(5)), id: \.self) { name in
                            Button {
                                viewModel.recipientName = name
                                recipientFocused = false
                                showSuggestions = false
                            } label: {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(ChipView.stableColor(for: name).opacity(0.15))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Text(String(name.prefix(1)).uppercased())
                                                .font(.caption2.weight(.bold))
                                                .foregroundStyle(ChipView.stableColor(for: name))
                                        )

                                    Text(name)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.WP.textPrimary)

                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(Color.WP.surface, in: RoundedRectangle(cornerRadius: DS.inputRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.inputRadius, style: .continuous)
                            .stroke(Color.WP.divider, lineWidth: 1)
                    )
                    .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Inline Result

    private func inlineResult(_ result: CreateRequestResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .overlay(Color.WP.divider)

            // Link + Copy
            HStack(spacing: 8) {
                Text(result.webURL)
                    .font(.caption.monospaced())
                    .lineLimit(2)
                    .foregroundStyle(Color.WP.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                #if canImport(UIKit)
                Button {
                    UIPasteboard.general.string = result.webURL
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.2)) { linkCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 0.2)) { linkCopied = false }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: linkCopied ? "checkmark" : "doc.on.doc")
                            .font(.caption2)
                            .contentTransition(.symbolEffect(.replace))
                        Text(linkCopied ? "Скопировано" : "Копировать")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(linkCopied ? Color.WP.green : Color.WP.accentDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous)
                            .stroke(linkCopied ? Color.WP.green.opacity(0.3) : Color.WP.divider, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                #endif
            }
            .padding(12)
            .background(Color.WP.surface, in: RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous))

            // Explanation
            Text("Вставьте ссылку в мессенджер и отправьте адресату. У него будет форма чтобы заполнить. Ваш список рецептов пополнился этим запросом.")
                .font(.caption)
                .foregroundStyle(Color.WP.textSecondary)
                .lineSpacing(3)

            // New request button
            Button {
                linkCopied = false
                viewModel.reset()
            } label: {
                Text("Сформировать новый запрос")
            }
            .buttonStyle(WPSecondaryButton())
        }
    }
}

// MARK: - Share Sheet

#if canImport(UIKit)
struct ShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
