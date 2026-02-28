#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct CreateRequestView: View {
    @State private var viewModel = CreateRequestViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let result = viewModel.result {
                        successSection(result)
                    } else {
                        formSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            .navigationTitle("Запросить рецепт")
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let result = viewModel.result {
                    ShareSheet(text: result.shareText)
                }
            }
        }
    }

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

    private func successSection(_ result: CreateRequestResponse) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Запрос создан!")
                .font(.title2.bold())

            Text("Ссылка отправлена через Share Sheet. Также можете скопировать её ниже.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            linkCard(result.webURL)

            HStack(spacing: 12) {
                Button {
                    viewModel.showShareSheet = true
                } label: {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

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

#if canImport(UIKit)
struct ShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
