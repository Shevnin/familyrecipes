#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct RequestHistorySection: View {
    let requests: [RecipeRequest]
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () async -> Void
    let onShare: (RecipeRequest) -> Void
    let canShare: (RecipeRequest) -> Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("История запросов")
                .font(.headline)

            if isLoading && requests.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else if let error = errorMessage, requests.isEmpty {
                VStack(spacing: 8) {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                    Button("Повторить") {
                        Task { await onRetry() }
                    }
                    .font(.footnote)
                }
            } else if requests.isEmpty {
                Text("Вы ещё не отправляли запросов.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(requests) { req in
                    requestRow(req)
                }
            }
        }
    }

    private func requestRow(_ req: RecipeRequest) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(req.dishName)
                        .font(.subheadline.weight(.medium))
                    Text("для \(req.recipientName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(req.statusLabel)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(req.statusColor.opacity(0.15))
                    .foregroundStyle(req.statusColor)
                    .clipShape(Capsule())
            }

            HStack {
                Text(req.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Spacer()

                if canShare(req) {
                    Button {
                        onShare(req)
                    } label: {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)

                    #if canImport(UIKit)
                    Button {
                        if let entry = LinkCacheStore.shared.entry(for: req.id) {
                            UIPasteboard.general.string = entry.webURL
                        }
                    } label: {
                        Label("Копировать", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    #endif
                }
            }
        }
        .padding(12)
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}
