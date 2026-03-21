#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct RequestHistorySection: View {
    let cards: [FamilyRecipeCard]
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () async -> Void
    let onShare: (FamilyRecipeCard) -> Void
    let canShare: (FamilyRecipeCard) -> Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ИСТОРИЯ ЗАПРОСОВ")
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(Color.WP.textSecondary)

            if isLoading && cards.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else if let error = errorMessage, cards.isEmpty {
                VStack(spacing: 8) {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Color.WP.red)
                    Button("Повторить") {
                        Task { await onRetry() }
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.WP.accentDark)
                }
            } else if cards.isEmpty {
                Text("Вы ещё не отправляли запросов.")
                    .font(.subheadline)
                    .foregroundStyle(Color.WP.textSecondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        cardRow(card)

                        if index != cards.index(before: cards.endIndex) {
                            Divider()
                                .overlay(Color.WP.divider)
                                .padding(.leading, 12)
                        }
                    }
                }
                .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous))
            }
        }
    }

    private func cardRow(_ card: FamilyRecipeCard) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.WP.textPrimary)
                    Text("для \(card.authorName)")
                        .font(.caption)
                        .foregroundStyle(Color.WP.textSecondary)
                }

                Spacer()

                Text(card.statusLabel)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(card.statusColor.opacity(0.12))
                    .foregroundStyle(card.statusColor)
                    .clipShape(RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous))
            }

            if canShare(card) {
                HStack {
                    Spacer()

                    HStack(spacing: 8) {
                        Button {
                            onShare(card)
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.caption2)
                                .foregroundStyle(Color.WP.accentDark)
                        }
                        .buttonStyle(.plain)

                        #if canImport(UIKit)
                        Button {
                            if let requestId = card.requestId,
                               let entry = LinkCacheStore.shared.entry(for: requestId) {
                                UIPasteboard.general.string = entry.webURL
                            }
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption2)
                                .foregroundStyle(Color.WP.accentDark)
                        }
                        .buttonStyle(.plain)
                        #endif
                    }
                }
            }
        }
        .padding(12)
    }
}
