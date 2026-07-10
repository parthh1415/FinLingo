import SpriteKit

/// The tall vertical world: stacks every stage as a `StageNode`, owns the player and camera,
/// runs the economy tick, and handles money-gated door transitions between stacked rooms.
final class WorldScene: SKScene {
    private enum Constants {
        static let movementSpeed: CGFloat = 75
        static let targetStoppingDistance: CGFloat = 4
        static let entryLocalY: CGFloat = 120   // open floor in the lower (door-side) region; clear of furniture and the door re-trigger zone
    }

    private let gameState: GameState
    private let economy: EconomyEngine
    private let stageController: StageController
    /// Called when the player taps the active stage's left laptop (Lessons).
    var onOpenLessons: (() -> Void)?
    /// Called when the player taps the active stage's right laptop (Simulator).
    var onOpenSimulator: (() -> Void)?

    private let cameraNode = SKCameraNode()
    private var cameraController: CameraController!
    private let player = PlayerNode()
    private var stageNodes: [StageNode] = []
    private var currentIndex = 0
    private var movementTarget: CGPoint?
    private var lastUpdateTime: TimeInterval = 0
    private var transitioning = false
    private var configured = false

    init(gameState: GameState, economy: EconomyEngine, stageController: StageController) {
        self.gameState = gameState
        self.economy = economy
        self.stageController = stageController
        super.init(size: DormRoomLayout.sceneSize)
        scaleMode = .aspectFit
        anchorPoint = .zero
        backgroundColor = PixelArtStyle.Palette.darkOutside
    }

    required init?(coder aDecoder: NSCoder) { nil }

    // MARK: - Setup

    override func didMove(to view: SKView) {
        guard !configured else { return }
        configured = true
        view.ignoresSiblingOrder = true
        view.shouldCullNonVisibleNodes = true
        physicsWorld.gravity = .zero

        let sceneCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        cameraNode.position = sceneCenter
        addChild(cameraNode)
        camera = cameraNode
        cameraController = CameraController(
            camera: cameraNode,
            roomHeight: stageController.stages.first?.roomHeight ?? size.height,
            sceneCenter: sceneCenter
        )

        for (index, stage) in stageController.stages.enumerated() {
            let node = StageNode(stage: stage)
            node.position = CGPoint(x: 0, y: -CGFloat(index) * stage.roomHeight)
            node.setLocked(!stageController.isUnlocked(index))
            addChild(node)
            stageNodes.append(node)
        }

        currentIndex = min(gameState.currentStageIndex, stageNodes.count - 1)
        economy.currentStage = stageNodes[currentIndex].stage
        cameraController.snap(toStageIndex: currentIndex)

        player.position = PixelArtStyle.pixelSnap(spawnScenePoint(forStage: currentIndex, local: DormRoomLayout.playerSpawn))
        player.zPosition = PixelArtStyle.Layer.player
        player.updateAnimation(direction: .up, moving: false)
        addChild(player)

        syncAllGear()
    }

    // MARK: - Frame loop

    override func update(_ currentTime: TimeInterval) {
        let dt: TimeInterval = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime

        economy.update(dt: dt)
        syncAllGear()

        // Unlock the next stage the moment the player can afford it.
        if currentIndex < stageNodes.count - 1, stageController.tryUnlockNext(from: currentIndex) {
            stageNodes[currentIndex + 1].setLocked(false)
        }

        updatePlayerMovement(deltaTime: CGFloat(dt))
        checkDoorTransition()
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        let hit = nodes(at: location)

        // Overclocking is driven by the dedicated on-screen button (OverclockButton),
        // not by tapping the GPU sprites on the map.

        // Left laptop opens Lessons, right laptop opens the Simulator.
        if let computer = stageNodes[currentIndex].computerNode,
           hit.contains(where: { $0 === computer || $0.parent === computer }) {
            onOpenLessons?()
            movementTarget = nil
            player.updateAnimation(direction: player.facingDirection, moving: false)
            return
        }
        if let simulator = stageNodes[currentIndex].simulatorNode,
           hit.contains(where: { $0 === simulator || $0.parent === simulator }) {
            onOpenSimulator?()
            movementTarget = nil
            player.updateAnimation(direction: player.facingDirection, moving: false)
            return
        }
        setMovementTarget(PixelArtStyle.pixelSnap(location))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        setMovementTarget(PixelArtStyle.pixelSnap(location))
    }

    // MARK: - Movement

    private func setMovementTarget(_ scenePoint: CGPoint) {
        guard walkable(scenePoint: scenePoint) else { movementTarget = nil; return }
        movementTarget = scenePoint
    }

    private func updatePlayerMovement(deltaTime: CGFloat) {
        guard let target = movementTarget else {
            player.updateAnimation(direction: player.facingDirection, moving: false)
            return
        }
        let delta = CGVector(dx: target.x - player.position.x, dy: target.y - player.position.y)
        let distance = hypot(delta.dx, delta.dy)
        guard distance > Constants.targetStoppingDistance else {
            movementTarget = nil
            player.position = PixelArtStyle.pixelSnap(player.position)
            player.updateAnimation(direction: player.facingDirection, moving: false)
            return
        }
        let step = min(Constants.movementSpeed * deltaTime, distance)
        let next = PixelArtStyle.pixelSnap(CGPoint(
            x: player.position.x + delta.dx / distance * step,
            y: player.position.y + delta.dy / distance * step
        ))
        guard walkable(scenePoint: next) else {
            movementTarget = nil
            player.updateAnimation(direction: player.facingDirection, moving: false)
            return
        }
        player.position = next
        player.zPosition = PixelArtStyle.Layer.player
        player.updateAnimation(direction: direction(for: delta), moving: true)
    }

    private func checkDoorTransition() {
        guard !transitioning,
              currentIndex < stageNodes.count - 1,
              stageController.isUnlocked(currentIndex + 1) else { return }
        let local = toLocal(player.position)
        if DormRoomLayout.doorwayRect.insetBy(dx: -3, dy: -3).contains(local) {
            beginTransition(to: currentIndex + 1)
        }
    }

    private func beginTransition(to index: Int) {
        transitioning = true
        movementTarget = nil
        currentIndex = index
        gameState.currentStageIndex = index
        economy.currentStage = stageNodes[index].stage
        cameraController.glide(toStageIndex: index, duration: 0.6)
        player.position = PixelArtStyle.pixelSnap(spawnScenePoint(forStage: index, local: CGPoint(x: DormRoomLayout.sceneSize.width / 2, y: Constants.entryLocalY)))
        player.updateAnimation(direction: .down, moving: false)
        run(.sequence([.wait(forDuration: 0.65), .run { [weak self] in self?.transitioning = false }]))
    }

    /// Recenters the camera on the current stage (driven by the HUD "Dorm" button).
    func recenterOnCurrentStage() {
        guard configured else { return }
        cameraController.glide(toStageIndex: currentIndex)
    }

    // MARK: - Helpers

    private var currentStageNode: StageNode { stageNodes[currentIndex] }

    private func toLocal(_ scenePoint: CGPoint) -> CGPoint {
        CGPoint(x: scenePoint.x - currentStageNode.position.x, y: scenePoint.y - currentStageNode.position.y)
    }

    private func walkable(scenePoint: CGPoint) -> Bool {
        currentStageNode.isWalkable(local: toLocal(scenePoint))
    }

    private func spawnScenePoint(forStage index: Int, local: CGPoint) -> CGPoint {
        CGPoint(x: local.x, y: local.y - CGFloat(index) * stageNodes[index].stage.roomHeight)
    }

    private func syncAllGear() {
        for node in stageNodes { node.syncGear(ownedGear: gameState.ownedGear) }
    }

    private func direction(for delta: CGVector) -> PlayerNode.Direction {
        if abs(delta.dx) > abs(delta.dy) { return delta.dx < 0 ? .left : .right }
        return delta.dy < 0 ? .down : .up
    }

    private func pulse(_ node: SKNode) {
        node.run(.sequence([.scale(to: 1.25, duration: 0.05), .scale(to: 1.0, duration: 0.07)]))
    }
}
