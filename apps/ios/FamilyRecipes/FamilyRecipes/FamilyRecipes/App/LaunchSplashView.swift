import SwiftUI

// MARK: - Step 1: Icon Splash (Warm Paper)

struct IconSplashView: View {
    var onTap: () -> Void
    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.WP.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 16) {
                        Image("app_icon_splash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text("FamilyRecipes")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(2)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.WP.textSecondary)
                    }

                    Spacer()

                    Text("Нажмите, чтобы продолжить")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.WP.textSecondary.opacity(0.5))
                        .padding(.bottom, geo.safeAreaInsets.bottom + 36)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                appeared = true
            }
        }
    }
}

// MARK: - Step 2: Photo + Quote Splash

struct PhotoSplashView: View {
    let item: ChefSplashItem
    var sessionReady: Bool
    var onTap: () -> Void

    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Full-screen chef photo
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                // Dark gradient overlay
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.15), location: 0.35),
                        .init(color: .black.opacity(0.72), location: 0.62),
                        .init(color: .black.opacity(0.92), location: 1.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // App wordmark — top left
                VStack {
                    HStack {
                        Text("FamilyRecipes")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .tracking(1.6)
                            .textCase(.uppercase)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, geo.safeAreaInsets.top + 18)
                    Spacer()
                }

                // Quote block + tap hint
                VStack(alignment: .leading, spacing: 0) {
                    Text("\u{201C}")
                        .font(.system(size: 64, weight: .black))
                        .foregroundStyle(.white.opacity(0.35))
                        .offset(x: -6, y: 12)
                        .frame(height: 32)

                    Text(item.quoteRu)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)

                    Rectangle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 32, height: 1)
                        .padding(.top, 20)
                        .padding(.bottom, 14)

                    Text(item.chefName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    Text(item.chefTitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 2)

                    Text("Нажмите, чтобы продолжить")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))
                        .padding(.top, 20)
                        .opacity(sessionReady ? 1 : 0)
                        .animation(.easeIn(duration: 0.3), value: sessionReady)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, geo.safeAreaInsets.bottom + 36)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onAppear {
            withAnimation(.easeOut(duration: 0.55).delay(0.15)) {
                appeared = true
            }
        }
    }
}

// MARK: - Previews

#Preview("Icon Splash") {
    IconSplashView(onTap: {})
}

#Preview("Photo Splash") {
    PhotoSplashView(
        item: ChefSplashData.all[0],
        sessionReady: true,
        onTap: {}
    )
}
