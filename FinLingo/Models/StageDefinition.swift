import CoreGraphics
import Foundation

/// A simple color value (with alpha used as tint strength) for per-stage room washes.
/// `a == 0` means "no tint" (used by the dorm, which keeps its original look).
struct RGBA: Equatable {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    let a: CGFloat

    static let none = RGBA(r: 0, g: 0, b: 0, a: 0)
}

/// Data describing one stage (room) in the dorm → garage → office → warehouse progression.
///
/// A stage is pure data so new stages cost a config value, not a new scene (design D7).
struct StageDefinition: Identifiable, Equatable {
    let id: String
    let displayName: String
    /// Gear offered by the marketplace while in this stage.
    let gearCatalog: [GearDefinition]
    /// Positions (in room-local coordinates) where purchased gear sprites are placed, in order.
    let gearSlots: [CGPoint]
    /// Cash required to unlock THIS stage. The first stage (dorm) is 0 (already unlocked).
    let unlockPrice: Int
    /// Compute→cash sell rate ($ per compute-sec). Higher stages convert faster.
    let computeToCashRate: Double
    /// Per-stage color wash so each stacked room reads as a different space. `.none` for dorm.
    let roomTint: RGBA
    /// Height of this room in scene units (stages stack by this amount). 512 for v1 stages.
    let roomHeight: CGFloat

    init(
        id: String,
        displayName: String,
        gearCatalog: [GearDefinition],
        gearSlots: [CGPoint],
        unlockPrice: Int,
        computeToCashRate: Double,
        roomTint: RGBA = .none,
        roomHeight: CGFloat = 512
    ) {
        self.id = id
        self.displayName = displayName
        self.gearCatalog = gearCatalog
        self.gearSlots = gearSlots
        self.unlockPrice = unlockPrice
        self.computeToCashRate = computeToCashRate
        self.roomTint = roomTint
        self.roomHeight = roomHeight
    }

    static func == (lhs: StageDefinition, rhs: StageDefinition) -> Bool {
        lhs.id == rhs.id
    }
}
