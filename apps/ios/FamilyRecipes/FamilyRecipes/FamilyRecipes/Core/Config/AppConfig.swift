import Foundation

enum AppConfig {
    private static let config: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            fatalError("Config.plist not found. Copy Config.example.plist to Core/Config/Config.plist and fill in values.")
        }
        return dict
    }()

    private static func string(for key: String) -> String {
        guard let value = config[key] as? String, !value.isEmpty else {
            fatalError("\(key) not set in Config.plist")
        }
        return value
    }

    static let supabaseURL = string(for: "SUPABASE_URL")
    static let supabaseAnonKey = string(for: "SUPABASE_ANON_KEY")
    static let functionsBaseURL = string(for: "FUNCTIONS_BASE_URL")
}
