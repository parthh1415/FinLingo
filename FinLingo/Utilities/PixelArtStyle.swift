import SpriteKit
import UIKit

enum PixelArtStyle {
    enum Layer {
        static let outside: CGFloat = -10
        static let floor: CGFloat = 0
        static let floorDetails: CGFloat = 2
        static let shadows: CGFloat = 8
        static let furniture: CGFloat = 10
        static let decorations: CGFloat = 14
        static let player: CGFloat = 20
        static let foreground: CGFloat = 30
        static let hud: CGFloat = 100
        static let dialogue: CGFloat = 110
    }

    enum Palette {
        static let darkOutside = UIColor(hex: "#111820")
        static let darkOutline = UIColor(hex: "#27232A")
        static let deepShadow = UIColor(hex: "#44302A")
        static let woodDarkest = UIColor(hex: "#4C3021")
        static let woodShadow = UIColor(hex: "#65412B")
        static let woodBase = UIColor(hex: "#966038")
        static let woodHighlight = UIColor(hex: "#BE8250")
        static let floorShadow = UIColor(hex: "#755035")
        static let floorBase = UIColor(hex: "#9B673E")
        static let floorHighlight = UIColor(hex: "#B77B48")
        static let wallShadow = UIColor(hex: "#B9A58E")
        static let wallBase = UIColor(hex: "#D8C7AC")
        static let wallHighlight = UIColor(hex: "#EEE0C5")
        static let blueBeddingDark = UIColor(hex: "#243B5A")
        static let blueBeddingBase = UIColor(hex: "#355A7D")
        static let blueHighlight = UIColor(hex: "#5F83A3")
        static let greenBeddingDark = UIColor(hex: "#294431")
        static let greenBeddingBase = UIColor(hex: "#426B48")
        static let greenHighlight = UIColor(hex: "#719365")
        static let laptopDark = UIColor(hex: "#262936")
        static let laptopCasing = UIColor(hex: "#555A68")
        static let screenBlue = UIColor(hex: "#67A6B8")
        static let screenHighlight = UIColor(hex: "#A9D8D6")
        static let plantDark = UIColor(hex: "#315438")
        static let plantBase = UIColor(hex: "#4F7B45")
        static let plantHighlight = UIColor(hex: "#83A85E")
        static let cardboardShadow = UIColor(hex: "#896139")
        static let cardboardBase = UIColor(hex: "#B78950")
        static let cardboardHighlight = UIColor(hex: "#D1A56B")
        static let uiCream = UIColor(hex: "#F2E4C4")
        static let uiBrown = UIColor(hex: "#51382B")
        static let uiAccent = UIColor(hex: "#D4A855")
        static let white = UIColor(hex: "#F8F1DC")
        static let lightGray = UIColor(hex: "#D6D9D8")
        static let navySeat = UIColor(hex: "#202C40")
        static let trashGray = UIColor(hex: "#777D82")
    }

    private static var textureCache: [String: SKTexture] = [:]

    static func pixelSnap(_ value: CGFloat) -> CGFloat {
        round(value)
    }

    static func pixelSnap(_ point: CGPoint) -> CGPoint {
        CGPoint(x: pixelSnap(point.x), y: pixelSnap(point.y))
    }

    static func loadPixelTexture(named name: String, size: CGSize) -> SKTexture {
        if let image = UIImage(named: name) {
            let texture = SKTexture(image: image)
            texture.filteringMode = .nearest
            return texture
        }

        let key = "\(name)-\(Int(size.width))x\(Int(size.height))"
        if let cached = textureCache[key] {
            return cached
        }

        // Placeholder for final asset named `name`; keeps the room playable until pixel art is supplied.
        let texture = createPlaceholderTexture(named: name, size: size)
        texture.filteringMode = .nearest
        textureCache[key] = texture
        return texture
    }

    static func textureFromImage(_ image: UIImage) -> SKTexture {
        let texture = SKTexture(image: image)
        texture.filteringMode = .nearest
        return texture
    }

    static func makeImage(size: CGSize, drawing: (CGContext, CGSize) -> Void) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setShouldAntialias(false)
            cgContext.interpolationQuality = .none
            drawing(cgContext, size)
        }
    }

    /// Draws the named pixel art as a `UIImage` — used by SwiftUI (e.g. the tutorial coach) as
    /// well as the SpriteKit texture path below, so both share one drawing routine.
    static func pixelArtImage(named name: String, size: CGSize) -> UIImage {
        makeImage(size: size) { context, canvas in
            switch name {
            case "dorm_floor":
                drawFloor(in: context, size: canvas)
            case "dorm_wall":
                fill(context, CGRect(origin: .zero, size: canvas), Palette.wallBase)
                rect(context, x: 0, y: 0, w: canvas.width, h: 4, Palette.wallHighlight)
                rect(context, x: 0, y: canvas.height - 5, w: canvas.width, h: 5, Palette.wallShadow)
            case "dorm_chair_rail":
                fill(context, CGRect(origin: .zero, size: canvas), Palette.wallShadow)
                rect(context, x: 0, y: 0, w: canvas.width, h: 2, Palette.wallHighlight)
            case "dorm_baseboard":
                fill(context, CGRect(origin: .zero, size: canvas), Palette.woodDarkest)
                rect(context, x: 0, y: 0, w: canvas.width, h: 2, Palette.woodHighlight)
            case "dorm_border":
                fill(context, CGRect(origin: .zero, size: canvas), Palette.wallHighlight)
                rect(context, x: 4, y: 4, w: canvas.width - 8, h: canvas.height - 8, Palette.woodDarkest)
                rect(context, x: 8, y: 8, w: canvas.width - 16, h: canvas.height - 16, UIColor.clear)
            case "dorm_door":
                fill(context, CGRect(origin: .zero, size: canvas), Palette.deepShadow)
                rect(context, x: 0, y: 0, w: 8, h: canvas.height, Palette.woodDarkest)
                rect(context, x: canvas.width - 8, y: 0, w: 8, h: canvas.height, Palette.woodDarkest)
            case "dorm_threshold":
                fill(context, CGRect(origin: .zero, size: canvas), UIColor(hex: "#637482"))
                rect(context, x: 0, y: 0, w: canvas.width, h: 2, UIColor(hex: "#93A1A9"))
                rect(context, x: 0, y: canvas.height - 3, w: canvas.width, h: 3, UIColor(hex: "#40505D"))
            case "dorm_window_01", "dorm_window_02", "dorm_window_03":
                drawWindow(in: context, size: canvas, foliageOffset: name == "dorm_window_02" ? 1 : name == "dorm_window_03" ? -1 : 0)
            case "window_foliage_01", "window_foliage_02", "window_foliage_03":
                drawFoliage(in: context, size: canvas, offset: name == "window_foliage_02" ? 1 : name == "window_foliage_03" ? -1 : 0)
            case "dorm_bed_blue":
                drawBed(in: context, size: canvas, blanket: Palette.blueBeddingBase, blanketDark: Palette.blueBeddingDark, highlight: Palette.blueHighlight)
            case "dorm_bed_green":
                drawBed(in: context, size: canvas, blanket: Palette.greenBeddingBase, blanketDark: Palette.greenBeddingDark, highlight: Palette.greenHighlight)
            case "dorm_desk":
                drawDesk(in: context, size: canvas)
            case "dorm_drawers", "dorm_dresser":
                drawDrawers(in: context, size: canvas)
            case "dorm_chair":
                drawChair(in: context, size: canvas)
            case "dorm_box":
                drawBox(in: context, size: canvas)
            case "dorm_backpack":
                drawBackpack(in: context, size: canvas)
            case "dorm_trash":
                drawTrash(in: context, size: canvas)
            case "dorm_pennant":
                drawPennant(in: context, size: canvas)
            case "dorm_poster":
                drawPoster(in: context, size: canvas)
            case "dorm_large_plant", "dorm_desk_plant":
                drawPlant(in: context, size: canvas, pot: name == "dorm_large_plant" ? Palette.woodShadow : Palette.white)
            case "dorm_picture_frame":
                drawPictureFrame(in: context, size: canvas)
            case "dorm_books":
                drawBooks(in: context, size: canvas)
            case "dorm_mug_white":
                drawMug(in: context, size: canvas, body: Palette.white, stripe: nil)
            case "dorm_mug_striped":
                drawMug(in: context, size: canvas, body: Palette.white, stripe: Palette.blueHighlight)
            case "laptop_left_01", "laptop_left_02", "laptop_left_03", "laptop_left_04":
                drawLaptop(in: context, size: canvas, screen: Palette.screenBlue, frameIndex: frameIndex(name))
            case "laptop_right_01", "laptop_right_02", "laptop_right_03", "laptop_right_04":
                drawLaptop(in: context, size: canvas, screen: Palette.laptopDark, frameIndex: frameIndex(name))
            case "coffee_steam_01", "coffee_steam_02", "coffee_steam_03":
                drawSteam(in: context, size: canvas, frameIndex: frameIndex(name))
            case "pet_cat":
                drawCat(in: context, size: canvas)
            case "player_down_idle", "player_down_walk_01", "player_down_walk_02", "player_down_walk_03",
                "player_up_idle", "player_up_walk_01", "player_up_walk_02", "player_up_walk_03",
                "player_left_idle", "player_left_walk_01", "player_left_walk_02", "player_left_walk_03",
                "player_right_idle", "player_right_walk_01", "player_right_walk_02", "player_right_walk_03":
                drawPlayer(in: context, size: canvas, name: name)
            default:
                fill(context, CGRect(origin: .zero, size: canvas), Palette.deepShadow)
                rect(context, x: 1, y: 1, w: canvas.width - 2, h: canvas.height - 2, Palette.woodBase)
                rect(context, x: 2, y: 2, w: canvas.width - 4, h: 2, Palette.woodHighlight)
            }
        }
    }

    private static func createPlaceholderTexture(named name: String, size: CGSize) -> SKTexture {
        SKTexture(image: pixelArtImage(named: name, size: size))
    }

    static func filledTexture(size: CGSize, color: UIColor, outline: UIColor? = nil) -> SKTexture {
        let key = "filled-\(Int(size.width))x\(Int(size.height))-\(color)-\(String(describing: outline))"
        if let cached = textureCache[key] {
            return cached
        }

        let image = makeImage(size: size) { context, canvas in
            fill(context, CGRect(origin: .zero, size: canvas), color)
            if let outline {
                rect(context, x: 0, y: 0, w: canvas.width, h: 1, outline)
                rect(context, x: 0, y: canvas.height - 1, w: canvas.width, h: 1, outline)
                rect(context, x: 0, y: 0, w: 1, h: canvas.height, outline)
                rect(context, x: canvas.width - 1, y: 0, w: 1, h: canvas.height, outline)
            }
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .nearest
        textureCache[key] = texture
        return texture
    }

    private static func drawFloor(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), Palette.floorBase)
        let tileW: CGFloat = 16
        let tileH: CGFloat = 28
        let rows = Int(ceil(size.height / tileH)) + 1
        let cols = Int(ceil(size.width / tileW)) + 2
        for row in 0..<rows {
            let offset = row.isMultiple(of: 2) ? CGFloat(0) : -tileW / 2
            for col in 0..<cols {
                let x = CGFloat(col) * tileW + offset
                let y = CGFloat(row) * tileH
                let tone = (row + col).isMultiple(of: 4) ? Palette.floorHighlight : (row + col).isMultiple(of: 3) ? Palette.floorShadow : Palette.floorBase
                rect(context, x: x, y: y, w: tileW - 1, h: tileH - 1, tone)
                rect(context, x: x, y: y + tileH - 1, w: tileW, h: 1, Palette.deepShadow.withAlphaComponent(0.45))
                rect(context, x: x + tileW - 1, y: y, w: 1, h: tileH, Palette.deepShadow.withAlphaComponent(0.35))
                rect(context, x: x + 3, y: y + 3, w: 1, h: 10, Palette.floorHighlight.withAlphaComponent(0.35))
                rect(context, x: x + tileW - 5, y: y + 12, w: 1, h: 9, Palette.floorShadow.withAlphaComponent(0.25))
            }
        }
    }

    private static func drawWindow(in context: CGContext, size: CGSize, foliageOffset: CGFloat) {
        fill(context, CGRect(origin: .zero, size: size), Palette.wallHighlight)
        rect(context, x: 2, y: 2, w: size.width - 4, h: size.height - 4, Palette.woodDarkest)
        rect(context, x: 5, y: 5, w: size.width - 10, h: size.height - 10, UIColor(hex: "#EEF0EA"))
        for y in stride(from: CGFloat(7), through: size.height - 12, by: 5) {
            rect(context, x: 6, y: y, w: size.width - 12, h: 2, Palette.lightGray)
        }
        drawFoliage(in: context, size: CGSize(width: size.width - 12, height: 6), origin: CGPoint(x: 6, y: size.height - 11), offset: foliageOffset)
    }

    private static func drawFoliage(in context: CGContext, size: CGSize, origin: CGPoint = .zero, offset: CGFloat) {
        for index in 0..<Int(size.width / 5) {
            let x = origin.x + CGFloat(index) * 5 + offset
            rect(context, x: x, y: origin.y + 2, w: 5, h: 3, index.isMultiple(of: 2) ? Palette.plantBase : Palette.plantDark)
            rect(context, x: x + 1, y: origin.y, w: 3, h: 2, Palette.plantHighlight)
        }
    }

    private static func drawBed(in context: CGContext, size: CGSize, blanket: UIColor, blanketDark: UIColor, highlight: UIColor) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        rect(context, x: 0, y: 0, w: size.width, h: size.height, Palette.woodDarkest)
        rect(context, x: 5, y: 8, w: size.width - 10, h: size.height - 16, Palette.woodShadow)
        rect(context, x: 8, y: 11, w: size.width - 16, h: size.height - 22, blanket)
        rect(context, x: 8, y: 11, w: size.width - 16, h: 8, highlight)
        rect(context, x: 11, y: 16, w: size.width - 22, h: 22, Palette.white)
        rect(context, x: 8, y: size.height - 45, w: size.width - 16, h: 34, blanketDark)
        rect(context, x: 13, y: size.height - 39, w: size.width - 26, h: 3, highlight)
        rect(context, x: 0, y: 0, w: size.width, h: 8, Palette.woodDarkest)
        rect(context, x: 0, y: size.height - 8, w: size.width, h: 8, Palette.woodDarkest)
        rect(context, x: 3, y: 2, w: size.width - 6, h: 2, Palette.woodHighlight)
    }

    private static func drawDesk(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), Palette.woodDarkest)
        rect(context, x: 3, y: 3, w: size.width - 6, h: size.height - 6, Palette.woodBase)
        rect(context, x: 4, y: 4, w: size.width - 8, h: 4, Palette.woodHighlight)
        rect(context, x: 0, y: size.height - 5, w: size.width, h: 5, Palette.woodShadow)
    }

    private static func drawDrawers(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), Palette.woodDarkest)
        rect(context, x: 3, y: 3, w: size.width - 6, h: size.height - 6, Palette.woodBase)
        rect(context, x: 5, y: 7, w: size.width - 10, h: 10, Palette.woodShadow)
        rect(context, x: 5, y: size.height - 17, w: size.width - 10, h: 10, Palette.woodShadow)
        rect(context, x: size.width / 2 - 2, y: 11, w: 4, h: 2, Palette.uiAccent)
        rect(context, x: size.width / 2 - 2, y: size.height - 13, w: 4, h: 2, Palette.uiAccent)
        rect(context, x: 4, y: 4, w: size.width - 8, h: 2, Palette.woodHighlight)
    }

    private static func drawChair(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        rect(context, x: 5, y: 0, w: size.width - 10, h: 9, Palette.woodShadow)
        rect(context, x: 7, y: 3, w: size.width - 14, h: 8, Palette.navySeat)
        rect(context, x: 4, y: 16, w: size.width - 8, h: 13, Palette.woodShadow)
        rect(context, x: 7, y: 18, w: size.width - 14, h: 8, Palette.navySeat)
        rect(context, x: 3, y: 5, w: 4, h: size.height - 8, Palette.woodDarkest)
        rect(context, x: size.width - 7, y: 5, w: 4, h: size.height - 8, Palette.woodDarkest)
    }

    private static func drawBox(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), Palette.cardboardShadow)
        rect(context, x: 2, y: 2, w: size.width - 4, h: size.height - 4, Palette.cardboardBase)
        rect(context, x: 3, y: 3, w: size.width - 6, h: 3, Palette.cardboardHighlight)
        rect(context, x: size.width / 2 - 1, y: 3, w: 2, h: size.height - 6, Palette.cardboardShadow)
    }

    private static func drawBackpack(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        rect(context, x: 5, y: 4, w: size.width - 10, h: size.height - 6, Palette.blueBeddingDark)
        rect(context, x: 8, y: 2, w: size.width - 16, h: 5, Palette.darkOutline)
        rect(context, x: 8, y: 7, w: size.width - 16, h: 3, Palette.blueHighlight)
        rect(context, x: 4, y: 10, w: 4, h: 8, Palette.darkOutline)
    }

    private static func drawTrash(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        rect(context, x: 3, y: 4, w: size.width - 6, h: size.height - 7, Palette.trashGray)
        rect(context, x: 1, y: 2, w: size.width - 2, h: 5, UIColor(hex: "#A6ADB1"))
        rect(context, x: 7, y: 0, w: 5, h: 5, Palette.white)
        rect(context, x: size.width - 10, y: 1, w: 5, h: 4, Palette.lightGray)
    }

    private static func drawPennant(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        context.setFillColor(Palette.blueBeddingBase.cgColor)
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: size.width, y: size.height / 2))
        context.addLine(to: CGPoint(x: 0, y: size.height))
        context.closePath()
        context.fillPath()
        rect(context, x: 2, y: size.height / 2 - 1, w: size.width / 2, h: 2, Palette.wallHighlight)
    }

    private static func drawPoster(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), Palette.woodDarkest)
        rect(context, x: 2, y: 2, w: size.width - 4, h: size.height - 4, Palette.wallHighlight)
        rect(context, x: 5, y: 5, w: size.width - 10, h: size.height / 2 - 4, Palette.blueHighlight)
        rect(context, x: 5, y: size.height - 8, w: size.width - 10, h: 2, Palette.blueBeddingBase)
    }

    private static func drawPlant(in context: CGContext, size: CGSize, pot: UIColor) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        rect(context, x: size.width / 2 - 8, y: size.height - 11, w: 16, h: 9, pot)
        rect(context, x: size.width / 2 - 6, y: size.height - 8, w: 12, h: 5, Palette.woodDarkest.withAlphaComponent(0.25))
        rect(context, x: size.width / 2 - 12, y: 8, w: 9, h: 12, Palette.plantDark)
        rect(context, x: size.width / 2 + 3, y: 7, w: 10, h: 13, Palette.plantBase)
        rect(context, x: size.width / 2 - 4, y: 2, w: 8, h: 15, Palette.plantHighlight)
        rect(context, x: size.width / 2 - 1, y: 14, w: 2, h: 11, Palette.plantDark)
    }

    private static func drawPictureFrame(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), Palette.blueBeddingBase)
        rect(context, x: 2, y: 2, w: size.width - 4, h: size.height - 4, Palette.wallHighlight)
        rect(context, x: 4, y: 4, w: size.width - 8, h: size.height - 8, Palette.blueHighlight)
    }

    private static func drawBooks(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        let colors = [UIColor(hex: "#8D3E35"), Palette.plantBase, Palette.wallHighlight, Palette.woodShadow, UIColor(hex: "#A8563D")]
        for index in 0..<5 {
            let x = CGFloat(index) * 5
            let height = size.height - CGFloat(index % 2) * 3
            rect(context, x: x, y: size.height - height, w: 4, h: height, colors[index])
            rect(context, x: x, y: size.height - height, w: 4, h: 1, Palette.darkOutline)
        }
    }

    private static func drawMug(in context: CGContext, size: CGSize, body: UIColor, stripe: UIColor?) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        rect(context, x: 2, y: 3, w: size.width - 5, h: size.height - 4, body)
        rect(context, x: size.width - 4, y: 5, w: 3, h: 5, body)
        rect(context, x: size.width - 3, y: 6, w: 1, h: 3, Palette.woodShadow)
        if let stripe {
            rect(context, x: 3, y: 5, w: size.width - 7, h: 2, stripe)
            rect(context, x: 3, y: 9, w: size.width - 7, h: 2, stripe)
        }
    }

    private static func drawLaptop(in context: CGContext, size: CGSize, screen: UIColor, frameIndex: Int) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        rect(context, x: 2, y: 2, w: size.width - 4, h: size.height - 5, Palette.laptopCasing)
        rect(context, x: 5, y: 4, w: size.width - 10, h: size.height - 10, screen)
        rect(context, x: 0, y: size.height - 5, w: size.width, h: 4, Palette.laptopDark)
        if frameIndex >= 2 {
            rect(context, x: 7, y: 7, w: 8, h: 1, Palette.screenHighlight)
        }
        if frameIndex >= 3 {
            rect(context, x: 7, y: 10, w: 14, h: 1, Palette.screenHighlight)
            rect(context, x: 7, y: 13, w: 10, h: 1, Palette.screenHighlight)
        }
        if frameIndex >= 4 {
            rect(context, x: size.width - 9, y: 13, w: 2, h: 4, Palette.wallHighlight)
        }
    }

    private static func drawSteam(in context: CGContext, size: CGSize, frameIndex: Int) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        let alpha: CGFloat = frameIndex == 3 ? 0.35 : 0.75
        let yOffset = CGFloat(frameIndex - 1)
        rect(context, x: 5, y: 6 - yOffset, w: 1, h: 5, Palette.wallHighlight.withAlphaComponent(alpha))
        rect(context, x: 8, y: 3 - yOffset, w: 1, h: 4, Palette.wallHighlight.withAlphaComponent(alpha))
        rect(context, x: 11, y: 7 - yOffset, w: 1, h: 4, Palette.wallHighlight.withAlphaComponent(alpha))
    }

    private static func drawPlayer(in context: CGContext, size: CGSize, name: String) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        // Only the limbs bob as she walks; the dress and hair hold still so the silhouette reads clean.
        let step: CGFloat = name.contains("walk_02") ? -1 : name.contains("walk_03") ? 1 : 0

        let dress = UIColor(hex: "#D46A8E")       // rosy dress — clearly feminine even at 18×26
        let dressDark = UIColor(hex: "#B24F72")
        let skin = UIColor(hex: "#C28A5E")
        let hair = UIColor(hex: "#4A2E28")        // long brown hair
        let hairDark = UIColor(hex: "#33201C")

        // Bare legs and little shoes peeking out below the skirt.
        rect(context, x: 6, y: 21 + step, w: 3, h: 4, skin)
        rect(context, x: 9, y: 21 - step, w: 3, h: 4, skin)
        rect(context, x: 6, y: 24 + step, w: 3, h: 1, hairDark)
        rect(context, x: 9, y: 24 - step, w: 3, h: 1, hairDark)

        // Flared skirt: a triangle that's widest at the hem — the giveaway shape.
        rect(context, x: 3, y: 17, w: 12, h: 4, dress)
        rect(context, x: 4, y: 14, w: 10, h: 3, dress)
        rect(context, x: 4, y: 20, w: 10, h: 1, dressDark)

        // Fitted bodice with a waist line.
        rect(context, x: 5, y: 8, w: 8, h: 7, dress)
        rect(context, x: 5, y: 13, w: 8, h: 1, dressDark)

        // Slim arms.
        rect(context, x: 3, y: 9 + step, w: 2, h: 6, skin)
        rect(context, x: 13, y: 9 - step, w: 2, h: 6, skin)

        // Head.
        rect(context, x: 6, y: 2, w: 7, h: 7, skin)

        // Direction-specific hair (always long past the shoulders) and face.
        if name.contains("up") {
            // Facing away: all hair, a curtain flowing down her back.
            rect(context, x: 5, y: 1, w: 9, h: 9, hair)
            rect(context, x: 5, y: 9, w: 9, h: 8, hair)
            rect(context, x: 8, y: 3, w: 2, h: 12, hairDark)   // center parting
        } else if name.contains("left") {
            rect(context, x: 6, y: 1, w: 8, h: 4, hair)        // crown
            rect(context, x: 12, y: 3, w: 3, h: 13, hair)      // long hair trailing behind
            rect(context, x: 5, y: 3, w: 3, h: 3, hair)        // front fringe
            rect(context, x: 6, y: 5, w: 1, h: 2, hairDark)    // eye
        } else if name.contains("right") {
            rect(context, x: 5, y: 1, w: 8, h: 4, hair)
            rect(context, x: 4, y: 3, w: 3, h: 13, hair)       // long hair trailing behind
            rect(context, x: 11, y: 3, w: 3, h: 3, hair)       // front fringe
            rect(context, x: 12, y: 5, w: 1, h: 2, hairDark)   // eye
        } else {
            // Facing the camera: bangs up top, two long locks framing her face.
            rect(context, x: 5, y: 1, w: 9, h: 3, hair)        // top
            rect(context, x: 4, y: 3, w: 2, h: 13, hair)       // left lock
            rect(context, x: 13, y: 3, w: 2, h: 13, hair)      // right lock
            rect(context, x: 6, y: 2, w: 7, h: 2, hair)        // fringe
            rect(context, x: 7, y: 5, w: 1, h: 2, hairDark)    // left eye
            rect(context, x: 11, y: 5, w: 1, h: 2, hairDark)   // right eye
            rect(context, x: 9, y: 7, w: 1, h: 1, dressDark)   // hint of a smile
        }
    }

    /// A little orange tabby, drawn front-on so it reads as a cat at 16×14. Tail sits on the
    /// right so a horizontal flip (see CatNode) gives it a touch of life when it turns.
    private static func drawCat(in context: CGContext, size: CGSize) {
        fill(context, CGRect(origin: .zero, size: size), UIColor.clear)
        let orange = UIColor(hex: "#E8974A")
        let orangeDk = UIColor(hex: "#C9762E")
        let pink = UIColor(hex: "#E9A6B0")
        let eye = UIColor(hex: "#2A2320")
        let cream = UIColor(hex: "#F8F1DC")

        // Tail curling up the right side (drawn first so the body overlaps its base).
        rect(context, x: 12, y: 8, w: 3, h: 2, orange)
        rect(context, x: 13, y: 4, w: 2, h: 4, orange)
        rect(context, x: 13, y: 3, w: 2, h: 1, orangeDk)

        // Ears.
        rect(context, x: 3, y: 0, w: 3, h: 3, orangeDk)
        rect(context, x: 4, y: 1, w: 1, h: 1, pink)
        rect(context, x: 10, y: 0, w: 3, h: 3, orangeDk)
        rect(context, x: 11, y: 1, w: 1, h: 1, pink)

        // Head with a little tabby "M" and eyes.
        rect(context, x: 3, y: 2, w: 10, h: 6, orange)
        rect(context, x: 6, y: 2, w: 1, h: 3, orangeDk)
        rect(context, x: 9, y: 2, w: 1, h: 3, orangeDk)
        rect(context, x: 5, y: 4, w: 2, h: 2, eye)
        rect(context, x: 9, y: 4, w: 2, h: 2, eye)
        rect(context, x: 6, y: 6, w: 4, h: 2, cream)   // muzzle
        rect(context, x: 7, y: 6, w: 2, h: 1, pink)    // nose

        // Body with a cream belly and side stripes.
        rect(context, x: 4, y: 8, w: 8, h: 5, orange)
        rect(context, x: 6, y: 9, w: 4, h: 4, cream)
        rect(context, x: 4, y: 9, w: 1, h: 3, orangeDk)
        rect(context, x: 11, y: 9, w: 1, h: 3, orangeDk)

        // Front paws.
        rect(context, x: 5, y: 12, w: 2, h: 1, cream)
        rect(context, x: 9, y: 12, w: 2, h: 1, cream)
    }

    private static func frameIndex(_ name: String) -> Int {
        if name.hasSuffix("_04") { return 4 }
        if name.hasSuffix("_03") { return 3 }
        if name.hasSuffix("_02") { return 2 }
        return 1
    }

    private static func fill(_ context: CGContext, _ rect: CGRect, _ color: UIColor) {
        context.setFillColor(color.cgColor)
        context.fill(rect.integral)
    }

    private static func rect(_ context: CGContext, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, _ color: UIColor) {
        guard w > 0, h > 0 else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: round(x), y: round(y), width: round(w), height: round(h)))
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        var value: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&value)

        let red = CGFloat((value >> 16) & 0xFF) / 255
        let green = CGFloat((value >> 8) & 0xFF) / 255
        let blue = CGFloat(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
