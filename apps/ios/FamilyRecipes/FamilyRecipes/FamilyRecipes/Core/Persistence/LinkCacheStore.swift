import Foundation

struct LinkCacheEntry: Codable {
    let webURL: String
    let shareText: String
}

@MainActor
@Observable
final class LinkCacheStore {
    static let shared = LinkCacheStore()
    private static let key = "fr_link_cache"

    private(set) var cache: [String: LinkCacheEntry] = [:]

    private init() {
        cache = LocalStore.load([String: LinkCacheEntry].self, key: Self.key) ?? [:]
    }

    func store(requestId: String, webURL: String, shareText: String) {
        cache[requestId] = LinkCacheEntry(webURL: webURL, shareText: shareText)
        LocalStore.save(cache, key: Self.key)
    }

    func entry(for requestId: String) -> LinkCacheEntry? {
        cache[requestId]
    }
}
