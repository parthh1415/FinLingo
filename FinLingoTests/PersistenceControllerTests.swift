import XCTest
@testable import FinLingo

final class PersistenceControllerTests: XCTestCase {

    func testRoundTrip() {
        PersistenceController.clear()

        let state = GameState(
            cash: 1234.5,
            ownedGear: ["h100": 3],
            unlockedStageIndex: 2
        )

        PersistenceController.save(state)

        let loaded = PersistenceController.load()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.cash ?? 0, 1234.5, accuracy: 0.0001)
        XCTAssertEqual(loaded?.ownedGear["h100"], 3)
        XCTAssertEqual(loaded?.unlockedStageIndex, 2)

        PersistenceController.clear()
    }

    func testLoadReturnsNilWhenNoFile() {
        PersistenceController.clear()
        XCTAssertNil(PersistenceController.load())
    }
}
