import CoreGraphics

enum DormRoomLayout {
    static let sceneSize = CGSize(width: 384, height: 512)
    static let roomRect = CGRect(x: 28, y: 48, width: 328, height: 416)
    static let interiorRect = CGRect(x: 40, y: 60, width: 304, height: 392)
    static let floorRect = CGRect(x: 40, y: 60, width: 304, height: 338)
    static let wallRect = CGRect(x: 40, y: 398, width: 304, height: 54)
    static let doorwayRect = CGRect(x: 162, y: 48, width: 60, height: 28)
    static let thresholdRect = CGRect(x: 160, y: 36, width: 64, height: 16)

    static let chairRailRect = CGRect(x: wallRect.minX, y: 421, width: wallRect.width, height: 7)
    static let baseboardRect = CGRect(x: wallRect.minX, y: 394, width: wallRect.width, height: 7)
    static let leftWallHighlightRect = CGRect(x: 48, y: 446, width: 54, height: 2)
    static let rightWallHighlightRect = CGRect(x: 282, y: 446, width: 54, height: 2)

    static let leftWindowRect = CGRect(x: 104, y: 426, width: 58, height: 28)
    static let rightWindowRect = CGRect(x: 222, y: 426, width: 58, height: 28)
    static let pennantRect = CGRect(x: 58, y: 430, width: 34, height: 17)
    static let posterRect = CGRect(x: 302, y: 425, width: 26, height: 23)

    static let leftBedRect = CGRect(x: 52, y: 276, width: 58, height: 120)
    static let rightBedRect = CGRect(x: 274, y: 276, width: 58, height: 120)
    static let deskRect = CGRect(x: 116, y: 330, width: 152, height: 40)
    static let leftDrawerRect = CGRect(x: 122, y: 292, width: 28, height: 32)
    static let rightDrawerRect = CGRect(x: 234, y: 292, width: 28, height: 32)
    static let leftChairRect = CGRect(x: 154, y: 282, width: 30, height: 32)
    static let rightChairRect = CGRect(x: 200, y: 282, width: 30, height: 32)
    static let leftDresserRect = CGRect(x: 56, y: 206, width: 48, height: 36)
    static let rightDresserRect = CGRect(x: 280, y: 206, width: 48, height: 36)

    static let pictureFrameRect = CGRect(x: 124, y: 352, width: 14, height: 13)
    static let leftLaptopPosition = CGPoint(x: 152, y: 358)
    static let whiteMugRect = CGRect(x: 173, y: 350, width: 11, height: 13)
    static let steamPosition = CGPoint(x: 178, y: 366)
    static let booksRect = CGRect(x: 190, y: 347, width: 24, height: 22)
    static let deskPlantRect = CGRect(x: 216, y: 346, width: 22, height: 24)
    static let rightLaptopPosition = CGPoint(x: 242, y: 358)
    static let stripedMugRect = CGRect(x: 258, y: 350, width: 11, height: 13)

    static let largePlantRect = CGRect(x: 65, y: 238, width: 28, height: 32)
    static let backpackRect = CGRect(x: 42, y: 166, width: 30, height: 24)
    static let movingBoxRect = CGRect(x: 289, y: 237, width: 30, height: 24)
    static let trashCanRect = CGRect(x: 326, y: 166, width: 22, height: 28)

    static let interactionDistance: CGFloat = 42
    static let playerRadius: CGFloat = 8
    static let playerSpawn = CGPoint(x: 192, y: 92)

    static let blockingFurniture: [CGRect] = [
        leftBedRect,
        rightBedRect,
        deskRect,
        leftDrawerRect,
        rightDrawerRect,
        leftChairRect,
        rightChairRect,
        leftDresserRect,
        rightDresserRect
    ]

    static func isPointWalkable(_ point: CGPoint, radius: CGFloat = playerRadius) -> Bool {
        let movementBounds = floorRect.union(doorwayRect).insetBy(dx: radius, dy: radius)
        guard movementBounds.contains(point) else { return false }

        let playerFootprint = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        return !blockingFurniture.contains { $0.intersects(playerFootprint) }
    }

    static func snapped(_ value: CGFloat) -> CGFloat {
        round(value)
    }

    static func snapped(_ point: CGPoint) -> CGPoint {
        CGPoint(x: snapped(point.x), y: snapped(point.y))
    }
}
