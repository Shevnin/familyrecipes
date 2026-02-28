#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct CreateRequestView: View {
    var requestDraft: RequestDraft
    @State private var viewModel = CreateRequestViewModel()

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        if let result = viewModel.result {
                            successSection(result, proxy: proxy)
                        } else {
                            if !viewModel.chipNames.isEmpty {
                                chipsSection
                            }
                            formSection
                        }

                        RequestHistorySection(
                            requests: viewModel.history,
                            isLoading: viewModel.isHistoryLoading,
                            errorMessage: viewModel.historyError,
                            onRetry: { await viewModel.loadHistory() },
                            onShare: { viewModel.shareRequest($0) },
                            canShare: { viewModel.canShareRequest($0) }
                        )
                        .id("history")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Запросить рецепт")
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let text = viewModel.activeShareText {
                    ShareSheet(text: text)
                }
            }
            .task {
                await viewModel.loadHistory()
            }
            .onChange(of: requestDraft.hasDraft) { _, hasDraft in
                if hasDraft {
                    let draft = requestDraft.consume()
                    viewModel.recipientName = draft.recipient
                    viewModel.dishName = draft.dish
                    viewModel.result = nil
                }
            }
        }
    }

    // MARK: - Chips

    private var chipsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Уже просили у…")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.chipNames, id: \.self) { name in
                        ChipView(
                            text: name,
                            isSelected: viewModel.recipientName.lowercased() == name.lowercased()
                        ) {
                            viewModel.recipientName = name
                        }
                    }
                }
            }
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Кому отправить?")
                    .font(.subheadline.weight(.medium))
                TextField("Имя (мама, бабушка Люда...)", text: $viewModel.recipientName)
                    .textContentType(.name)
                    .padding()
                    .background(.fill.tertiary, in: .rect(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Какой рецепт?")
                    .font(.subheadline.weight(.medium))
                TextField("Борщ, пирожки с мясом...", text: $viewModel.dishName)
                    .padding()
                    .background(.fill.tertiary, in: .rect(cornerRadius: 12))
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task { await viewModel.createRequest() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Отправить запрос")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 24)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
            .padding(.top, 8)
        }
    }

    // MARK: - Success

    private func successSection(_ result: CreateRequestResponse, proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Запрос создан!")
                .font(.title2.bold())

            Text("Отправьте ссылку получателю — он заполнит рецепт через форму.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            linkCard(result.webURL)

            VStack(spacing: 12) {
                Text("Что дальше?")
                    .font(.headline)

                Button {
                    viewModel.showShareSheet = true
                } label: {
                    Label("Поделиться ссылкой", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                HStack(spacing: 12) {
                    #if canImport(UIKit)
                    Button {
                        UIPasteboard.general.string = result.webURL
                    } label: {
                        Label("Копировать", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    #endif

                    Button {
                        withAnimation {
                            proxy.scrollTo("history", anchor: .top)
                        }
                    } label: {
                        Label("История", systemImage: "list.bullet")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button {
                    viewModel.reset()
                } label: {
                    Text("Новый запрос")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    // MARK: - Link Card

    private func linkCard(_ url: String) -> some View {
        HStack {
            Text(url)
                .font(.caption.monospaced())
                .lineLimit(2)
                .foregroundStyle(.secondary)

            Spacer()

            #if canImport(UIKit)
            Button {
                UIPasteboard.general.string = url
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            #endif
        }
        .padding()
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
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

