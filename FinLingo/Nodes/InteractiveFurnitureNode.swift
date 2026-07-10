import SpriteKit

final class InteractiveFurnitureNode: SKSpriteNode {
    let interactionMessage: String
    let interactionPoint: CGPoint
    let interactionDistance: CGFloat

    init(
        texture: SKTexture,
        size: CGSize,
        interactionMessage: String,
        interactionPoint: CGPoint,
        interactionDistance: CGFloat = DormRoomLayout.interactionDistance
    ) {
        self.interactionMessage = interactionMessage
        self.interactionPoint = interactionPoint
        self.interactionDistance = interactionDistance
        super.init(texture: texture, color: .clear, size: size)
        name = "interactiveFurniture"
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func canInteract(playerPosition: CGPoint) -> Bool {
        InteractionRules.canInteract(
            playerPosition: playerPosition,
            targetPosition: interactionPoint,
            maxDistance: interactionDistance
        )
    }
}

enum InteractionRules {
    static func canInteract(playerPosition: CGPoint, targetPosition: CGPoint, maxDistance: CGFloat) -> Bool {
        hypot(playerPosition.x - targetPosition.x, playerPosition.y - targetPosition.y) <= maxDistance
    }
}
