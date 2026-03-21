import SwiftUI

struct CreditsView: View {
    var body: some View {
        List {
            Section {
                Text("Фотографии шефов на стартовом экране используются по свободным лицензиям Wikimedia Commons. Лицензии CC BY и CC BY-SA требуют указания авторства.")
                    .font(.footnote)
                    .foregroundStyle(Color.WP.textSecondary)
                    .listRowBackground(Color.clear)
            }

            Section("Фотографии") {
                ForEach(ChefSplashData.all) { item in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.chefName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.WP.textPrimary)
                        Text("© \(item.photoAttribution) · \(item.photoLicense)")
                            .font(.caption)
                            .foregroundStyle(Color.WP.textSecondary)
                    }
                    .padding(.vertical, 2)
                    .listRowBackground(Color.clear)
                }
            }

            Section("Цитаты") {
                Text("Цитаты принадлежат упомянутым авторам. Оригинальные тексты на английском; русские переводы созданы для этого приложения.")
                    .font(.footnote)
                    .foregroundStyle(Color.WP.textSecondary)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .wpList()
        .listRowSeparatorTint(Color.WP.divider)
        .navigationTitle("Авторские права")
        .navigationBarTitleDisplayMode(.inline)
    }
}
