import SwiftUI

struct ChipView: View {
    let text: String
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button { action?() } label: {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(chipColor.opacity(isSelected ? 0.3 : 0.15))
                .foregroundStyle(chipColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(chipColor.opacity(0.3), lineWidth: isSelected ? 1.5 : 0)
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
