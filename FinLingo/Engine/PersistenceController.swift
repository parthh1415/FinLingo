import Foundation

enum PersistenceController {
    /// The on-disk location of the save file: Application Support/finlingo_save.json.
    /// Computed once; the Application Support directory is created if it does not exist.
    private static let saveURL: URL = {
        let fileManager = FileManager.default
        let baseDirectory = fileManager
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? fileManager.temporaryDirectory

        try? fileManager.createDirectory(
            at: baseDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        return baseDirectory.appendingPathComponent("finlingo_save.json")
    }()

    /// Encodes the state to JSON and writes it to Application Support/finlingo_save.json (atomically).
    static func save(_ state: GameState) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(state) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }

    /// Loads and decodes the saved state, or nil if the file is missing/unreadable/corrupt.
    static func load() -> GameState? {
        guard FileManager.default.fileExists(atPath: saveURL.path) else { return nil }
        guard let data = try? Data(contentsOf: saveURL) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try? decoder.decode(GameState.self, from: data)
    }

    /// Removes the save file if present (useful for tests/reset).
    static func clear() {
        try? FileManager.default.removeItem(at: saveURL)
    }
}
