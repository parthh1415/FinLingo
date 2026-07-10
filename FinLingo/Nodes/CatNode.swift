import SpriteKit

/// The shop pet: a little cat that trails the player. WorldScene owns the follow behaviour;
/// this node just holds the art and flips to face the way it's travelling.
final class CatNode: SKSpriteNode {
    private let artSize = CGSize(width: 16, height: 14)
    /// Renders the art a touch larger; nearest-neighbor keeps the pixels crisp.
    private let displayScale: CGFloat = 1.2

    init() {
        let texture = PixelArtStyle.loadPixelTexture(named: "pet_cat", size: artSize)
        super.init(texture: texture, color: .clear, size: artSize)
        name = "pet_cat"
        anchorPoint = CGPoint(x: 0.5, y: 0.3)
        zPosition = PixelArtStyle.Layer.player - 1   // sits just behind the player
        setScale(displayScale)
    }

    required init?(coder aDecoder: NSCoder) { nil }

    /// Face the direction of travel by flipping horizontally (only on a clear sideways move).
    func face(dx: CGFloat) {
        guard abs(dx) > 0.5 else { return }
        xScale = (dx < 0 ? -1 : 1) * displayScale
    }
}
