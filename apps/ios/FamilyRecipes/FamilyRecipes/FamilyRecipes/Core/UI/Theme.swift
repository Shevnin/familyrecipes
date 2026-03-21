import SwiftUI

// MARK: - Warm Paper Color Palette

extension Color {
    /// Warm Paper design tokens from accepted Stitch baseline.
    enum WP {
        static let background    = Color(hex: 0xFCF9F4)
        static let surface       = Color.white
        static let surfaceSoft   = Color(hex: 0xF6F3EE)
        static let surfaceMuted  = Color(hex: 0xEBE8E3)

        static let textPrimary   = Color(hex: 0x1C1C19)
        static let textSecondary = Color(hex: 0x666666)

        static let divider       = Color(hex: 0xE5E1D8)
        static let outlineVariant = Color(hex: 0xDBC2AD)

        static let accent        = Color(hex: 0xFF9900)
        static let accentDark    = Color(hex: 0x8A5100)
        static let red           = Color(hex: 0xDF2D1F)
        static let green         = Color(hex: 0x228B22)
        static let greenDark     = Color(hex: 0x006E0C)
    }

    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// MARK: - Design Tokens

enum DS {
    static let rowRadius: CGFloat    = 4
    static let panelRadius: CGFloat  = 8
    static let inputRadius: CGFloat  = 7
    static let buttonRadius: CGFloat = 8
    static let screenPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 20
    static let rowVerticalPadding: CGFloat = 12
}

// MARK: - View Helpers

extension View {
    func wpSurface(padding: CGFloat = 16, radius: CGFloat = DS.panelRadius) -> some View {
        self
            .padding(padding)
            .background(Color.WP.surface, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    func wpSoftSurface(padding: CGFloat = 16, radius: CGFloat = DS.panelRadius) -> some View {
        self
            .padding(padding)
            .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    func wpInput() -> some View {
        self
            .padding(12)
            .background(Color.WP.surfaceSoft, in: RoundedRectangle(cornerRadius: DS.inputRadius, style: .continuous))
    }

    func wpBackground() -> some View {
        self.background(Color.WP.background)
    }

    func wpList() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.WP.background)
    }
}

// MARK: - Button Styles

struct WPPrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isEnabled ? Color.WP.accent : Color.WP.accent.opacity(0.4),
                in: RoundedRectangle(cornerRadius: DS.buttonRadius, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct WPSecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.WP.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Color.WP.surfaceMuted,
                in: RoundedRectangle(cornerRadius: DS.buttonRadius, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Empty / Error State

struct WPFeedbackState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.WP.accent)

            VStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.WP.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.WP.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(WPPrimaryButton())
                    .frame(width: 180)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DS.screenPadding)
        .wpBackground()
    }
}

// MARK: - Global Appearance

#if canImport(UIKit)
enum WPAppearance {
    static func configure() {
        let paperBg = UIColor(Color.WP.background)
        let dividerColor = UIColor(Color.WP.divider)
        let primaryColor = UIColor(Color.WP.accent)
        let secondaryText = UIColor(Color.WP.textSecondary)
        let titleColor = UIColor(Color.WP.textPrimary)

        // Navigation bar
        let nav = UINavigationBarAppearance()
        nav.configureWithDefaultBackground()
        nav.backgroundColor = paperBg
        nav.shadowColor = dividerColor
        nav.titleTextAttributes = [.foregroundColor: titleColor]
        nav.largeTitleTextAttributes = [.foregroundColor: titleColor]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = primaryColor

        // Tab bar
        let tab = UITabBarAppearance()
        tab.configureWithDefaultBackground()
        tab.backgroundColor = paperBg
        tab.shadowColor = dividerColor
        let stacked = tab.stackedLayoutAppearance
        stacked.normal.iconColor = secondaryText
        stacked.normal.titleTextAttributes = [
            .foregroundColor: secondaryText,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
        ]
        stacked.selected.iconColor = primaryColor
        stacked.selected.titleTextAttributes = [
            .foregroundColor: primaryColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .bold),
        ]

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = tab
        tabBar.scrollEdgeAppearance = tab
        tabBar.tintColor = primaryColor
        tabBar.unselectedItemTintColor = secondaryText
        tabBar.selectionIndicatorImage = selectionIndicator(color: primaryColor)
    }

    private static func selectionIndicator(color: UIColor) -> UIImage? {
        let size = CGSize(width: 4, height: 49)
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            let context = rendererContext.cgContext
            context.clear(CGRect(origin: .zero, size: size))
            color.withAlphaComponent(0.16).setFill()
            UIBezierPath(
                roundedRect: CGRect(x: 0, y: 4, width: size.width, height: size.height - 8),
                cornerRadius: 2
            ).fill()
            color.setFill()
            UIBezierPath(
                roundedRect: CGRect(x: 0, y: size.height - 3, width: size.width, height: 3),
                cornerRadius: 1.5
            ).fill()
        }.resizableImage(withCapInsets: .zero)
    }
}
#endif
