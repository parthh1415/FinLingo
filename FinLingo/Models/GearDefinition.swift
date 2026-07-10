import CoreGraphics
import Foundation

/// A purchasable piece of hardware. Bought with cash from the marketplace; each unit
/// owned adds `computePerSecond` to the player's production rate (see §5 / §6).
struct GearDefinition: Identifiable, Equatable, Hashable {
    let id: String
    let displayName: String
    /// Cash price for one unit.
    let cost: Int
    /// Compute/sec added to production per unit owned.
    let computePerSecond: Double
    /// Pixel-art texture name. PixelArtStyle falls back to a placeholder if no PNG exists.
    let spriteName: String

    init(
        id: String,
        displayName: String,
        cost: Int,
        computePerSecond: Double,
        spriteName: String
    ) {
        self.id = id
        self.displayName = displayName
        self.cost = cost
        self.computePerSecond = computePerSecond
        self.spriteName = spriteName
    }
}
