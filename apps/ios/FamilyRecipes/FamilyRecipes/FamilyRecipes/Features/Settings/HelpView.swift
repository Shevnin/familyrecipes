import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DS.sectionSpacing) {
                ForEach(HelpContent.sections, id: \.title) { section in
                    HelpSectionCard(section: section)
                }
            }
            .padding(DS.screenPadding)
        }
        .wpBackground()
        .navigationTitle(HelpContent.screenTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Section Card

private struct HelpSectionCard: View {
    let section: HelpSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.WP.accentDark)
                    .frame(width: 20)

                Text(section.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.WP.textPrimary)
            }

            Text(section.body)
                .font(.subheadline)
                .foregroundStyle(Color.WP.textPrimary.opacity(0.85))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.WP.surface, in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous)
                .stroke(Color.WP.divider, lineWidth: 1)
        )
    }
}
