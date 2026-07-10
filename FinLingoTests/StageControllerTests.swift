import XCTest
@testable import FinLingo

final class StageControllerTests: XCTestCase {

    // MARK: - Helpers

    private func makeStage(id: String, unlockPrice: Int) -> StageDefinition {
        StageDefinition(
            id: id,
            displayName: id.capitalized,
            gearCatalog: [],
            gearSlots: [],
            unlockPrice: unlockPrice,
            computeToCashRate: 1.0,
            roomTint: RGBA(r: 0, g: 0, b: 0, a: 0),
            roomHeight: 512
        )
    }

    private func twoStages() -> [StageDefinition] {
        [
            makeStage(id: "dorm", unlockPrice: 0),
            makeStage(id: "garage", unlockPrice: 5000)
        ]
    }

    // MARK: - Tests

    func testDormIsAlwaysUnlocked() {
        let state = GameState(cash: 0, unlockedStageIndex: 0)
        let controller = StageController(stages: twoStages(), gameState: state)
        XCTAssertTrue(controller.isUnlocked(0))
    }

    func testCannotUnlockNextWithoutEnoughCash() {
        let state = GameState(cash: 0, unlockedStageIndex: 0)
        let controller = StageController(stages: twoStages(), gameState: state)

        XCTAssertFalse(controller.isUnlocked(1))
        XCTAssertFalse(controller.canUnlockNext(from: 0))
        XCTAssertFalse(controller.tryUnlockNext(from: 0))
        XCTAssertEqual(state.unlockedStageIndex, 0)
    }

    func testUnlockNextWithEnoughCash() {
        let state = GameState(cash: 5000, unlockedStageIndex: 0)
        let controller = StageController(stages: twoStages(), gameState: state)

        XCTAssertTrue(controller.canUnlockNext(from: 0))
        XCTAssertTrue(controller.tryUnlockNext(from: 0))
        XCTAssertEqual(state.unlockedStageIndex, 1)
        XCTAssertTrue(controller.isUnlocked(1))

        // Already unlocked: a second attempt is a no-op and returns false.
        XCTAssertFalse(controller.tryUnlockNext(from: 0))
        XCTAssertEqual(state.unlockedStageIndex, 1)
    }

    func testUnlockPriceForNext() {
        let state = GameState(cash: 0, unlockedStageIndex: 0)
        let controller = StageController(stages: twoStages(), gameState: state)

        XCTAssertEqual(controller.unlockPrice(forNext: 0), 5000)
        // Last index has no next stage.
        XCTAssertNil(controller.unlockPrice(forNext: 1))
    }
}
