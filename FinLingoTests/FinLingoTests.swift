//
//  FinLingoTests.swift
//  FinLingoTests
//
//

import Testing
import CoreGraphics
@testable import FinLingo

struct FinLingoTests {

    @MainActor
    @Test func initialGameStateUsesDormRoomDefaults() async throws {
        let state = GameState()

        #expect(state.cash == 500)
        #expect(state.companyName == "Dorm Room Labs")
        #expect(state.currentStageIndex == 0)
        #expect(state.unlockedStageIndex == 0)
    }

    @MainActor
    @Test func laptopInteractionUsesDistanceThreshold() async throws {
        let laptop = DormRoomLayout.leftLaptopPosition
        let nearbyPlayer = CGPoint(x: laptop.x + 30, y: laptop.y)
        let distantPlayer = CGPoint(x: laptop.x + 60, y: laptop.y)

        #expect(InteractionRules.canInteract(
            playerPosition: nearbyPlayer,
            targetPosition: laptop,
            maxDistance: DormRoomLayout.interactionDistance
        ))
        #expect(!InteractionRules.canInteract(
            playerPosition: distantPlayer,
            targetPosition: laptop,
            maxDistance: DormRoomLayout.interactionDistance
        ))
    }

    @MainActor
    @Test func furnitureCollisionAreaIsNotWalkable() async throws {
        let pointInsideLeftBed = CGPoint(
            x: DormRoomLayout.leftBedRect.midX,
            y: DormRoomLayout.leftBedRect.midY
        )

        #expect(!DormRoomLayout.isPointWalkable(pointInsideLeftBed))
    }

    @MainActor
    @Test func portraitSceneKeepsSpawnAndOpenFloorWalkable() async throws {
        #expect(DormRoomLayout.sceneSize.height > DormRoomLayout.sceneSize.width)
        #expect(DormRoomLayout.isPointWalkable(DormRoomLayout.playerSpawn))
        #expect(DormRoomLayout.isPointWalkable(CGPoint(x: DormRoomLayout.sceneSize.width / 2, y: 160)))
    }

}
