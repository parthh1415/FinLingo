import SpriteKit

/// Controls vertical camera movement across a tall world of stacked rooms.
///
/// The world is composed of equally sized rooms stacked vertically. Stage 0
/// (the dorm) sits at `sceneCenter`, and each subsequent stage is one
/// `roomHeight` lower in the SpriteKit coordinate space (rooms stack downward
/// by subtracting `roomHeight`). The camera moves vertically to center
/// whichever stage is active while keeping its x fixed at `sceneCenter.x`.
final class CameraController {

    /// The camera node this controller drives.
    private let camera: SKCameraNode

    /// The height of a single room in points.
    private let roomHeight: CGFloat

    /// The scene center used as the anchor for stage 0 and the fixed x position.
    private let sceneCenter: CGPoint

    /// Action key used for animated camera glides so they don't stack.
    private static let glideKey = "cameraGlide"

    /// Creates a camera controller.
    /// - Parameters:
    ///   - camera: The `SKCameraNode` to move.
    ///   - roomHeight: The height of one room in points.
    ///   - sceneCenter: The anchor point centering stage 0 (also the fixed x).
    init(camera: SKCameraNode, roomHeight: CGFloat, sceneCenter: CGPoint) {
        self.camera = camera
        self.roomHeight = roomHeight
        self.sceneCenter = sceneCenter
    }

    /// The camera Y that centers the given stage. Stage 0 = `sceneCenter.y`;
    /// each higher index is one `roomHeight` lower (further down the world).
    /// - Parameter index: The zero-based stage index.
    /// - Returns: The y coordinate that vertically centers the stage.
    func centerY(forStageIndex index: Int) -> CGFloat {
        return sceneCenter.y - CGFloat(index) * roomHeight
    }

    /// Instantly moves the camera to center the given stage.
    /// The x position stays at `sceneCenter.x`.
    /// - Parameter index: The zero-based stage index to center.
    func snap(toStageIndex index: Int) {
        camera.position = CGPoint(x: sceneCenter.x, y: centerY(forStageIndex: index))
    }

    /// Animates the camera to center the given stage with ease-in/ease-out.
    /// Any in-flight glide is removed first so glides don't stack.
    /// - Parameters:
    ///   - index: The zero-based stage index to center.
    ///   - duration: The animation duration in seconds. Defaults to 0.6.
    func glide(toStageIndex index: Int, duration: TimeInterval = 0.6) {
        camera.removeAction(forKey: CameraController.glideKey)
        let destination = CGPoint(x: sceneCenter.x, y: centerY(forStageIndex: index))
        let action = SKAction.move(to: destination, duration: duration)
        action.timingMode = .easeInEaseOut
        camera.run(action, withKey: CameraController.glideKey)
    }
}
