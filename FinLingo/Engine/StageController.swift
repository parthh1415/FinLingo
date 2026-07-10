import Combine
import Foundation

/// Coordinates stage unlock progression (dorm → garage → office → warehouse).
///
/// Unlocking is a *threshold*, not a purchase: reaching the required cash for the
/// next stage permanently unlocks it without deducting any cash. The controller
/// reads/writes `GameState.unlockedStageIndex` and never mutates `cash`.
final class StageController: ObservableObject {
    /// The ordered list of stage definitions (index 0 = dorm).
    let stages: [StageDefinition]

    private let gameState: GameState

    init(stages: [StageDefinition], gameState: GameState) {
        self.stages = stages
        self.gameState = gameState
    }

    /// Whether the stage at `index` is unlocked (index 0 is always unlocked).
    /// Out-of-range (negative or beyond the unlocked frontier) returns false.
    func isUnlocked(_ index: Int) -> Bool {
        index >= 0 && index <= gameState.unlockedStageIndex
    }

    /// The cash price required to unlock the stage after `fromIndex`.
    /// Returns nil if there is no next stage.
    func unlockPrice(forNext fromIndex: Int) -> Int? {
        let next = fromIndex + 1
        guard next >= 0, next < stages.count else { return nil }
        return stages[next].unlockPrice
    }

    /// Whether the next stage exists, is not already unlocked, and the player has
    /// enough cash to meet its unlock threshold.
    func canUnlockNext(from index: Int) -> Bool {
        let next = index + 1
        guard next < stages.count else { return false }
        // Only the immediate frontier can be unlocked — never skip a stage.
        guard next == gameState.unlockedStageIndex + 1 else { return false }
        return gameState.cash >= Double(stages[next].unlockPrice)
    }

    /// Attempts to unlock the next stage. On success, advances
    /// `unlockedStageIndex` (never regressing it) and returns true. Does not
    /// deduct cash.
    @discardableResult
    func tryUnlockNext(from index: Int) -> Bool {
        guard canUnlockNext(from: index) else { return false }
        gameState.unlockedStageIndex = max(gameState.unlockedStageIndex, index + 1)
        return true
    }
}
