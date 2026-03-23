import SwiftUI

struct MainTabView: View {
    @Bindable var appState: AppState
    @State private var selectedTab = 0
    @State private var requestDraft = RequestDraft()
    @State private var cardsViewModel = RecipesViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipesView(requestDraft: requestDraft, selectedTab: $selectedTab, viewModel: cardsViewModel)
                .tabItem {
                    Label("Рецепты", systemImage: "fork.knife")
                }
                .tag(0)

            CreateRequestView(requestDraft: requestDraft, cardsViewModel: cardsViewModel)
                .tabItem {
                    Label("Запросить", systemImage: "square.and.pencil")
                }
                .tag(1)

            SettingsView(appState: appState)
                .tabItem {
                    Label("Ещё", systemImage: "ellipsis.circle")
                }
                .tag(2)
        }
        .tint(Color.WP.accent)
    }
}

// MARK: - Settings

private struct SettingsView: View {
    let appState: AppState
    @State private var showingLogoutConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.sectionSpacing) {
                    VStack(spacing: 0) {
                        NavigationLink {
                            ContactsView()
                        } label: {
                            settingsRow(title: "Семья и друзья", systemImage: "person.2")
                        }

                        Divider()
                            .overlay(Color.WP.divider)
                            .padding(.leading, 52)

                        NavigationLink {
                            EquipmentView()
                        } label: {
                            settingsRow(title: "Моё оборудование", systemImage: "fork.knife.circle")
                        }

                        Divider()
                            .overlay(Color.WP.divider)
                            .padding(.leading, 52)

                        NavigationLink {
                            HelpView()
                        } label: {
                            settingsRow(title: "Как это работает", systemImage: "questionmark.circle")
                        }

                        Divider()
                            .overlay(Color.WP.divider)
                            .padding(.leading, 52)

                        NavigationLink {
                            CreditsView()
                        } label: {
                            settingsRow(title: "Авторские права", systemImage: "c.circle")
                        }
                    }
                    .background(Color.WP.surface, in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous))

                    Button(role: .destructive) {
                        showingLogoutConfirm = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.subheadline.weight(.semibold))
                                .frame(width: 20)
                            Text("Выйти из аккаунта")
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                        }
                        .foregroundStyle(Color.WP.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.WP.surface, in: RoundedRectangle(cornerRadius: DS.panelRadius, style: .continuous))
                    }
                }
                .padding(DS.screenPadding)
            }
            .wpBackground()
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Выйти из аккаунта?", isPresented: $showingLogoutConfirm) {
                Button("Выйти", role: .destructive) {
                    Task { await appState.signOut() }
                }
            }
        }
    }

    private func settingsRow(title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(width: 20)
                .foregroundStyle(Color.WP.accentDark)

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.WP.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.WP.textSecondary.opacity(0.35))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
