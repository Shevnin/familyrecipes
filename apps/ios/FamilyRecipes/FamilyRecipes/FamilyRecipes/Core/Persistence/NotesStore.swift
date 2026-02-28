import Foundation

struct RecipeNote: Codable {
    var text: String
    var updatedAt: Date
}

@MainActor
@Observable
final class NotesStore {
    static let shared = NotesStore()
    private static let key = "fr_recipe_notes"

    private(set) var notes: [String: RecipeNote] = [:]

    private init() {
        notes = LocalStore.load([String: RecipeNote].self, key: Self.key) ?? [:]
    }

    func note(for recipeId: String) -> RecipeNote? {
        notes[recipeId]
    }

    func save(text: String, for recipeId: String) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notes.removeValue(forKey: recipeId)
        } else {
            notes[recipeId] = RecipeNote(text: text, updatedAt: Date())
        }
        LocalStore.save(notes, key: Self.key)
    }

    func hasNote(for recipeId: String) -> Bool {
        guard let n = notes[recipeId] else { return false }
        return !n.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
