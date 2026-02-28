import SwiftUI

struct MainTabView: View {
    @Bindable var appState: AppState
    @State private var selectedTab = 0
    @State private var requestDraft = RequestDraft()

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipesView(requestDraft: requestDraft, selectedTab: $selectedTab)
                .tabItem {
                    Label("Рецепты", systemImage: "book")
                }
                .tag(0)

            CreateRequestView(requestDraft: requestDraft)
                .tabItem {
                    Label("Запросить", systemImage: "paperplane")
                }
                .tag(1)

            SettingsView(appState: appState)
                .tabItem {
                    Label("Ещё", systemImage: "ellipsis")
                }
                .tag(2)
        }
    }
}

private struct SettingsView: View {
    let appState: AppState
    @State private var showingLogoutConfirm = false

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ContactsView()
                } label: {
                    Label("Семья и друзья", systemImage: "person.2")
                }

                Button("Выйти из аккаунта", role: .destructive) {
                    showingLogoutConfirm = true
                }
            }
            .navigationTitle("Настройки")
            .confirmationDialog("Выйти из аккаунта?", isPresented: $showingLogoutConfirm) {
                Button("Выйти", role: .destructive) {
                    Task { await appState.signOut() }
                }
            }
        }
    }
}
