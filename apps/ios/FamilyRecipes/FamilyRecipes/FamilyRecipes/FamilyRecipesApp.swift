import SwiftUI

@main
struct FamilyRecipesApp: App {
    @State private var appState = AppState()
    @State private var introStep: IntroStep = .icon
    @State private var sessionReady = false
    @State private var photoTapRequested = false

    private let splashItem = ChefSplashData.random()

    init() {
        #if canImport(UIKit)
        WPAppearance.configure()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch introStep {
                case .icon:
                    IconSplashView(onTap: advanceToPhoto)
                        .transition(.opacity)

                case .photo:
                    PhotoSplashView(
                        item: splashItem,
                        sessionReady: sessionReady,
                        onTap: handlePhotoTap
                    )
                    .transition(.opacity)

                case .done:
                    if appState.isLoggedIn {
                        MainTabView(appState: appState)
                    } else {
                        AuthView(appState: appState)
                    }
                }
            }
            .animation(.easeOut(duration: 0.3), value: introStep)
            .task {
                await appState.checkSession()
                sessionReady = true
                if photoTapRequested && introStep == .photo {
                    finishIntro()
                }
            }
        }
    }

    private func advanceToPhoto() {
        introStep = .photo
    }

    private func handlePhotoTap() {
        if sessionReady {
            finishIntro()
        } else {
            photoTapRequested = true
        }
    }

    private func finishIntro() {
        introStep = .done
    }
}

private enum IntroStep {
    case icon, photo, done
}
