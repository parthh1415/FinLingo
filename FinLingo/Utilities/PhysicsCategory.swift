import Foundation

enum PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let wall: UInt32 = 1 << 1
    static let furniture: UInt32 = 1 << 2
    static let interactive: UInt32 = 1 << 3
}
