import SpriteKit

final class PlayerNode: SKSpriteNode {
    enum Direction: String {
        case down
        case up
        case left
        case right
    }

    private(set) var facingDirection: Direction = .down
    private var isWalking = false
    private let playerSize = CGSize(width: 18, height: 26)
    /// Renders the 18×26 art a touch larger on screen; nearest-neighbor keeps the pixels crisp.
    private let displayScale: CGFloat = 1.3

    init() {
        let texture = PixelArtStyle.loadPixelTexture(named: "player_down_idle", size: playerSize)
        super.init(texture: texture, color: .clear, size: playerSize)
        name = "player"
        zPosition = PixelArtStyle.Layer.player
        anchorPoint = CGPoint(x: 0.5, y: 0.28)
        setScale(displayScale)
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 14, height: 10), center: CGPoint(x: 0, y: 4))
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.furniture
        physicsBody?.contactTestBitMask = PhysicsCategory.interactive
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 1
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func updateAnimation(direction: Direction, moving: Bool) {
        guard direction != facingDirection || moving != isWalking else { return }

        facingDirection = direction
        isWalking = moving
        removeAction(forKey: "playerAnimation")

        if moving {
            let textures = walkingTextures(for: direction)
            let animation = SKAction.repeatForever(
                SKAction.animate(with: textures, timePerFrame: 0.12, resize: false, restore: false)
            )
            run(animation, withKey: "playerAnimation")
        } else {
            texture = idleTexture(for: direction)
        }
    }

    private func idleTexture(for direction: Direction) -> SKTexture {
        PixelArtStyle.loadPixelTexture(named: "player_\(direction.rawValue)_idle", size: playerSize)
    }

    private func walkingTextures(for direction: Direction) -> [SKTexture] {
        [
            PixelArtStyle.loadPixelTexture(named: "player_\(direction.rawValue)_walk_01", size: playerSize),
            PixelArtStyle.loadPixelTexture(named: "player_\(direction.rawValue)_walk_02", size: playerSize),
            PixelArtStyle.loadPixelTexture(named: "player_\(direction.rawValue)_walk_03", size: playerSize),
            PixelArtStyle.loadPixelTexture(named: "player_\(direction.rawValue)_walk_02", size: playerSize)
        ]
    }
}
