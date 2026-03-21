import SwiftUI

struct ChipView: View {
    let text: String
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button { action?() } label: {
            Text(text)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(chipColor.opacity(isSelected ? 0.25 : 0.12))
                .foregroundStyle(chipColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(chipColor.opacity(isSelected ? 0.4 : 0), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var chipColor: Color {
        Self.stableColor(for: text)
    }

    static func stableColor(for name: String) -> Color {
        let palette: [Color] = [
            .blue, .purple, .pink, .orange, .teal,
            .green, .indigo, .mint, .cyan, .brown
        ]
        let hash = deterministicHash(name)
        return palette[hash % palette.count]
    }

    private static func deterministicHash(_ s: String) -> Int {
        var hash = 5381
        for byte in s.lowercased().utf8 {
            hash = ((hash &<< 5) &+ hash) &+ Int(byte)
        }
        return abs(hash)
    }
}
