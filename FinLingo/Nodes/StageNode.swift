import SpriteKit

/// One room in the stacked world, built in LOCAL coordinates (origin bottom-left, size
/// 384 × roomHeight). `WorldScene` positions each StageNode at a vertical offset to stack
/// the rooms. Movement blocking is geometric (`DormRoomLayout.isPointWalkable`) — no physics.
final class StageNode: SKNode {
    let stage: StageDefinition
    let roomSize: CGSize

    /// The left laptop the player taps to open Lessons.
    private(set) var computerNode: InteractiveFurnitureNode!
    /// The right laptop the player taps to open the Simulator.
    private(set) var simulatorNode: InteractiveFurnitureNode!
    /// The door sprite at the bottom of the room.
    private(set) var doorNode: SKSpriteNode!

    private var placedGearSnapshot: [String: Int] = [:]
    private var shroudRoot: SKNode?

    init(stage: StageDefinition) {
        self.stage = stage
        self.roomSize = CGSize(width: DormRoomLayout.sceneSize.width, height: stage.roomHeight)
        super.init()
        buildRoom()
    }

    required init?(coder aDecoder: NSCoder) { nil }

    // MARK: - Public room API

    var playerSpawnLocal: CGPoint { DormRoomLayout.playerSpawn }
    var doorwayRectLocal: CGRect { DormRoomLayout.doorwayRect }
    func isWalkable(local: CGPoint) -> Bool { DormRoomLayout.isPointWalkable(local) }

    /// Ensures one sprite per owned gear unit for THIS stage's catalog appears in the room.
    func syncGear(ownedGear: [String: Int]) {
        for gear in stage.gearCatalog {
            let owned = ownedGear[gear.id, default: 0]
            let placed = placedGearSnapshot[gear.id, default: 0]
            guard owned > placed else { continue }
            for _ in placed..<owned { placeGear(gear) }
            placedGearSnapshot[gear.id] = owned
        }
    }

    /// Shows/hides the lock shroud + price teaser.
    func setLocked(_ locked: Bool) {
        if locked {
            guard shroudRoot == nil else { return }
            let root = SKNode()
            root.zPosition = PixelArtStyle.Layer.foreground + 5

            let shade = SKSpriteNode(color: UIColor(white: 0.02, alpha: 0.72), size: roomSize)
            shade.position = CGPoint(x: roomSize.width / 2, y: roomSize.height / 2)
            root.addChild(shade)

            let lock = makeLabel(text: "🔒", size: 28, alignment: .center)
            lock.position = CGPoint(x: roomSize.width / 2, y: roomSize.height / 2 + 18)
            root.addChild(lock)

            let teaser = makeLabel(text: "\(stage.displayName) — $\(stage.unlockPrice)", size: 13, alignment: .center)
            teaser.position = CGPoint(x: roomSize.width / 2, y: roomSize.height / 2 - 16)
            root.addChild(teaser)

            addChild(root)
            shroudRoot = root
        } else {
            guard let root = shroudRoot else { return }
            shroudRoot = nil
            root.run(.sequence([.fadeOut(withDuration: 0.4), .removeFromParent()]))
        }
    }

    // MARK: - Build

    private func buildRoom() {
        createOutsideBackground()
        createFloor()
        createRoomBorder()
        createWalls()
        createWindows()
        createWallDecorations()
        createBeds()
        createDeskArea()
        createSideFurniture()
        createDoorway()
        applyTint()
        addBanner()
    }

    private func createOutsideBackground() {
        let outside = SKSpriteNode(
            texture: PixelArtStyle.filledTexture(size: roomSize, color: PixelArtStyle.Palette.darkOutside),
            size: roomSize
        )
        outside.position = CGPoint(x: roomSize.width / 2, y: roomSize.height / 2)
        outside.zPosition = PixelArtStyle.Layer.outside
        addChild(outside)
    }

    private func createFloor() {
        addSprite(named: "dorm_floor", rect: DormRoomLayout.floorRect, zPosition: PixelArtStyle.Layer.floor)
    }

    private func createRoomBorder() {
        let room = DormRoomLayout.roomRect
        let doorway = DormRoomLayout.doorwayRect
        let outerThickness: CGFloat = 5
        let trimThickness: CGFloat = 3
        let bottomLeftWidth = doorway.minX - room.minX
        let bottomRightX = doorway.maxX
        let bottomRightWidth = room.maxX - doorway.maxX

        addBorderStrip(rect: CGRect(x: room.minX, y: room.maxY - outerThickness, width: room.width, height: outerThickness), color: PixelArtStyle.Palette.wallHighlight)
        addBorderStrip(rect: CGRect(x: room.minX, y: room.minY, width: bottomLeftWidth, height: outerThickness), color: PixelArtStyle.Palette.wallHighlight)
        addBorderStrip(rect: CGRect(x: bottomRightX, y: room.minY, width: bottomRightWidth, height: outerThickness), color: PixelArtStyle.Palette.wallHighlight)
        addBorderStrip(rect: CGRect(x: room.minX, y: room.minY, width: outerThickness, height: room.height), color: PixelArtStyle.Palette.wallHighlight)
        addBorderStrip(rect: CGRect(x: room.maxX - outerThickness, y: room.minY, width: outerThickness, height: room.height), color: PixelArtStyle.Palette.wallHighlight)

        addBorderStrip(rect: CGRect(x: room.minX + outerThickness, y: room.maxY - outerThickness - trimThickness, width: room.width - outerThickness * 2, height: trimThickness), color: PixelArtStyle.Palette.woodDarkest)
        addBorderStrip(rect: CGRect(x: room.minX + outerThickness, y: room.minY + outerThickness, width: bottomLeftWidth - outerThickness, height: trimThickness), color: PixelArtStyle.Palette.woodDarkest)
        addBorderStrip(rect: CGRect(x: bottomRightX, y: room.minY + outerThickness, width: bottomRightWidth - outerThickness, height: trimThickness), color: PixelArtStyle.Palette.woodDarkest)
        addBorderStrip(rect: CGRect(x: room.minX + outerThickness, y: room.minY + outerThickness, width: trimThickness, height: room.height - outerThickness * 2), color: PixelArtStyle.Palette.woodDarkest)
        addBorderStrip(rect: CGRect(x: room.maxX - outerThickness - trimThickness, y: room.minY + outerThickness, width: trimThickness, height: room.height - outerThickness * 2), color: PixelArtStyle.Palette.woodDarkest)
    }

    private func createWalls() {
        addSprite(named: "dorm_wall", rect: DormRoomLayout.wallRect, zPosition: PixelArtStyle.Layer.floorDetails)
        addSprite(named: "dorm_chair_rail", rect: DormRoomLayout.chairRailRect, zPosition: PixelArtStyle.Layer.decorations)
        addSprite(named: "dorm_baseboard", rect: DormRoomLayout.baseboardRect, zPosition: PixelArtStyle.Layer.decorations)
        addHighlight(rect: DormRoomLayout.leftWallHighlightRect)
        addHighlight(rect: DormRoomLayout.rightWallHighlightRect)
    }

    private func createWindows() {
        let left = addSprite(named: "dorm_window_01", rect: DormRoomLayout.leftWindowRect, zPosition: PixelArtStyle.Layer.decorations)
        addAnimatedFoliage(to: left)
        let right = addSprite(named: "dorm_window_01", rect: DormRoomLayout.rightWindowRect, zPosition: PixelArtStyle.Layer.decorations)
        addAnimatedFoliage(to: right)
    }

    private func createWallDecorations() {
        addSprite(named: "dorm_pennant", rect: DormRoomLayout.pennantRect, zPosition: PixelArtStyle.Layer.decorations)
        addSprite(named: "dorm_poster", rect: DormRoomLayout.posterRect, zPosition: PixelArtStyle.Layer.decorations)
    }

    private func createBeds() {
        addFurniture(named: "dorm_bed_blue", rect: DormRoomLayout.leftBedRect)
        addFurniture(named: "dorm_bed_green", rect: DormRoomLayout.rightBedRect)
    }

    private func createDeskArea() {
        addFurniture(named: "dorm_desk", rect: DormRoomLayout.deskRect)
        addFurniture(named: "dorm_drawers", rect: DormRoomLayout.leftDrawerRect)
        addFurniture(named: "dorm_drawers", rect: DormRoomLayout.rightDrawerRect)
        addFurniture(named: "dorm_chair", rect: DormRoomLayout.leftChairRect)
        addFurniture(named: "dorm_chair", rect: DormRoomLayout.rightChairRect)
        addDeskObjects()
    }

    private func addDeskObjects() {
        addSprite(named: "dorm_picture_frame", rect: DormRoomLayout.pictureFrameRect, zPosition: PixelArtStyle.Layer.decorations)
        addLaptop(namedPrefix: "laptop_left", position: DormRoomLayout.leftLaptopPosition, size: CGSize(width: 30, height: 20), initialDelay: 0, isComputer: true)
        addSprite(named: "dorm_mug_white", rect: DormRoomLayout.whiteMugRect, zPosition: PixelArtStyle.Layer.decorations)
        addSteam(at: DormRoomLayout.steamPosition)
        addSprite(named: "dorm_books", rect: DormRoomLayout.booksRect, zPosition: PixelArtStyle.Layer.decorations)
        addSprite(named: "dorm_desk_plant", rect: DormRoomLayout.deskPlantRect, zPosition: PixelArtStyle.Layer.decorations)
        addLaptop(namedPrefix: "laptop_right", position: DormRoomLayout.rightLaptopPosition, size: CGSize(width: 30, height: 20), initialDelay: 0.35, isComputer: false)
        addSprite(named: "dorm_mug_striped", rect: DormRoomLayout.stripedMugRect, zPosition: PixelArtStyle.Layer.decorations)
    }

    private func createSideFurniture() {
        addFurniture(named: "dorm_dresser", rect: DormRoomLayout.leftDresserRect)
        addSprite(named: "dorm_large_plant", rect: DormRoomLayout.largePlantRect, zPosition: PixelArtStyle.Layer.decorations)
        addSprite(named: "dorm_backpack", rect: DormRoomLayout.backpackRect, zPosition: PixelArtStyle.Layer.furniture)
        addFurniture(named: "dorm_dresser", rect: DormRoomLayout.rightDresserRect)
        addSprite(named: "dorm_box", rect: DormRoomLayout.movingBoxRect, zPosition: PixelArtStyle.Layer.decorations)
        addSprite(named: "dorm_trash", rect: DormRoomLayout.trashCanRect, zPosition: PixelArtStyle.Layer.furniture)
    }

    private func createDoorway() {
        doorNode = addSprite(named: "dorm_door", rect: DormRoomLayout.doorwayRect, zPosition: PixelArtStyle.Layer.foreground + 1)
        addSprite(named: "dorm_threshold", rect: DormRoomLayout.thresholdRect, zPosition: PixelArtStyle.Layer.foreground + 1)
    }

    private func applyTint() {
        guard stage.roomTint.a > 0 else { return }
        let tint = SKSpriteNode(
            color: UIColor(red: stage.roomTint.r, green: stage.roomTint.g, blue: stage.roomTint.b, alpha: 1),
            size: roomSize
        )
        tint.alpha = stage.roomTint.a
        tint.position = CGPoint(x: roomSize.width / 2, y: roomSize.height / 2)
        tint.zPosition = PixelArtStyle.Layer.decorations + 1
        tint.blendMode = .alpha
        addChild(tint)
    }

    private func addBanner() {
        let banner = makeLabel(text: stage.displayName.uppercased(), size: 11, alignment: .center)
        banner.position = CGPoint(x: roomSize.width / 2, y: roomSize.height - 22)
        banner.zPosition = PixelArtStyle.Layer.decorations + 2
        addChild(banner)
    }

    // MARK: - Gear

    private func placeGear(_ gear: GearDefinition) {
        let index = children.reduce(0) { $0 + ($1.name == "rigGear" ? 1 : 0) }
        let spriteSize = CGSize(width: 22, height: 16)
        let node = SKSpriteNode(
            texture: PixelArtStyle.loadPixelTexture(named: gear.spriteName, size: spriteSize),
            size: spriteSize
        )
        node.name = "rigGear"
        node.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        node.position = PixelArtStyle.pixelSnap(gearSlot(forIndex: index))
        node.zPosition = PixelArtStyle.Layer.furniture
        addChild(node)
    }

    private func gearSlot(forIndex index: Int) -> CGPoint {
        guard !stage.gearSlots.isEmpty else { return DormRoomLayout.leftLaptopPosition }
        if index < stage.gearSlots.count { return stage.gearSlots[index] }
        let base = stage.gearSlots[stage.gearSlots.count - 1]
        let overflow = index - stage.gearSlots.count + 1
        return CGPoint(x: base.x + CGFloat(overflow) * 6, y: base.y + CGFloat(overflow) * 6)
    }

    // MARK: - Sprite helpers (add to self; no physics)

    @discardableResult
    private func addSprite(named textureName: String, rect: CGRect, zPosition: CGFloat) -> SKSpriteNode {
        let texture = PixelArtStyle.loadPixelTexture(named: textureName, size: rect.size)
        let node = SKSpriteNode(texture: texture, size: rect.size)
        node.position = PixelArtStyle.pixelSnap(CGPoint(x: rect.midX, y: rect.midY))
        node.zPosition = zPosition
        addChild(node)
        return node
    }

    @discardableResult
    private func addFurniture(named textureName: String, rect: CGRect) -> SKSpriteNode {
        addContactShadow(for: rect)
        return addSprite(named: textureName, rect: rect, zPosition: PixelArtStyle.Layer.furniture)
    }

    private func addContactShadow(for rect: CGRect) {
        let shadowRect = rect.offsetBy(dx: 3, dy: -4)
        let shadow = SKSpriteNode(
            texture: PixelArtStyle.filledTexture(size: shadowRect.size, color: PixelArtStyle.Palette.deepShadow.withAlphaComponent(0.36)),
            size: shadowRect.size
        )
        shadow.position = PixelArtStyle.pixelSnap(CGPoint(x: shadowRect.midX, y: shadowRect.midY))
        shadow.zPosition = PixelArtStyle.Layer.shadows
        addChild(shadow)
    }

    private func addHighlight(rect: CGRect) {
        let node = SKSpriteNode(texture: PixelArtStyle.filledTexture(size: rect.size, color: PixelArtStyle.Palette.wallHighlight), size: rect.size)
        node.position = PixelArtStyle.pixelSnap(CGPoint(x: rect.midX, y: rect.midY))
        node.zPosition = PixelArtStyle.Layer.decorations
        addChild(node)
    }

    private func addBorderStrip(rect: CGRect, color: UIColor) {
        let node = SKSpriteNode(texture: PixelArtStyle.filledTexture(size: rect.size, color: color), size: rect.size)
        node.position = PixelArtStyle.pixelSnap(CGPoint(x: rect.midX, y: rect.midY))
        node.zPosition = PixelArtStyle.Layer.foreground
        addChild(node)
    }

    private func addLaptop(namedPrefix: String, position: CGPoint, size: CGSize, initialDelay: TimeInterval, isComputer: Bool) {
        let frames = (1...4).map { PixelArtStyle.loadPixelTexture(named: "\(namedPrefix)_0\($0)", size: size) }
        let laptop = InteractiveFurnitureNode(
            texture: frames[0],
            size: size,
            // Left laptop teaches; right laptop is the practice simulator.
            interactionMessage: isComputer ? "Open Lessons" : "Open Simulator",
            interactionPoint: position
        )
        laptop.position = PixelArtStyle.pixelSnap(position)
        laptop.zPosition = PixelArtStyle.Layer.decorations
        addChild(laptop)
        if isComputer { computerNode = laptop } else { simulatorNode = laptop }

        let animation = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.18, resize: false, restore: true))
        laptop.run(SKAction.sequence([.wait(forDuration: initialDelay), animation]), withKey: "laptopScreen")

        let cursor = SKSpriteNode(texture: PixelArtStyle.filledTexture(size: CGSize(width: 2, height: 4), color: PixelArtStyle.Palette.wallHighlight), size: CGSize(width: 2, height: 4))
        cursor.position = CGPoint(x: size.width / 2 - 8, y: 2)
        cursor.zPosition = PixelArtStyle.Layer.foreground
        laptop.addChild(cursor)
        cursor.run(.repeatForever(.sequence([.unhide(), .wait(forDuration: 0.55), .hide(), .wait(forDuration: 0.35)])), withKey: "cursorBlink")
    }

    private func addAnimatedFoliage(to window: SKSpriteNode) {
        let size = CGSize(width: 48, height: 7)
        let foliage = SKSpriteNode(texture: PixelArtStyle.loadPixelTexture(named: "window_foliage_01", size: size), size: size)
        foliage.position = CGPoint(x: 0, y: -9)
        foliage.zPosition = PixelArtStyle.Layer.foreground
        window.addChild(foliage)
        let frames = (1...3).map { PixelArtStyle.loadPixelTexture(named: "window_foliage_0\($0)", size: size) }
        foliage.run(.repeatForever(.animate(with: frames, timePerFrame: 0.4, resize: false, restore: true)), withKey: "foliageMovement")
    }

    private func addSteam(at position: CGPoint) {
        let size = CGSize(width: 16, height: 14)
        let steam = SKSpriteNode(texture: PixelArtStyle.loadPixelTexture(named: "coffee_steam_01", size: size), size: size)
        steam.position = PixelArtStyle.pixelSnap(position)
        steam.zPosition = PixelArtStyle.Layer.foreground
        addChild(steam)
        let frames = (1...3).map { PixelArtStyle.loadPixelTexture(named: "coffee_steam_0\($0)", size: size) }
        steam.run(.repeatForever(.sequence([.animate(with: frames, timePerFrame: 0.18, resize: false, restore: true), .wait(forDuration: 1.1)])), withKey: "coffeeSteam")
    }

    private func makeLabel(text: String, size: CGFloat, alignment: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = text
        label.fontSize = size
        label.fontColor = PixelArtStyle.Palette.uiCream
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = alignment
        label.zPosition = PixelArtStyle.Layer.foreground + 6
        return label
    }
}
