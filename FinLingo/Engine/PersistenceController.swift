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
        // Never let a stray NaN/Inf make the whole save silently fail (default is .throw).
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "inf", negativeInfinity: "-inf", nan: "0")

        guard let data = try? encoder.encode(state) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }

    /// Loads and decodes the saved state, or nil if there is no readable save yet.
    ///
    /// A file that exists but fails to decode is *quarantined* (moved to `.corrupt`) rather than
    /// left in place — otherwise the caller boots a fresh state and the next `save()` would
    /// silently overwrite the user's real, recoverable data.
    static func load() -> GameState? {
        guard FileManager.default.fileExists(atPath: saveURL.path) else { return nil }
        guard let data = try? Data(contentsOf: saveURL) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "inf", negativeInfinity: "-inf", nan: "0")

        do {
            let state = try decoder.decode(GameState.self, from: data)
            state.sanitize()   // drop any non-finite numbers an older save may carry
            return state
        } catch {
            // Decodable but corrupt: set it aside so we can start clean without destroying it.
            let quarantine = saveURL.appendingPathExtension("corrupt")
            try? FileManager.default.removeItem(at: quarantine)
            try? FileManager.default.moveItem(at: saveURL, to: quarantine)
            return nil
        }
    }

    /// Removes the save file and any quarantined copy — a clean wipe (reset / "erase progress").
    static func clear() {
        try? FileManager.default.removeItem(at: saveURL)
        try? FileManager.default.removeItem(at: saveURL.appendingPathExtension("corrupt"))
    }
}
