//
//  TitleView.swift
//  FinLingo
//
//  The home screen shown on every launch: a framed "Level 1: Freshman Year" dorm diorama over a
//  campus backdrop, the FinLingo wordmark, and a game-style control bar — Load Game, Start New
//  Life, Settings. The pixel hero is drawn procedurally with Canvas so it scales crisply.
//

import SwiftUI

struct TitleView: View {
    @Binding var hasSave: Bool
    var onNewLife: () -> Void
    var onLoad: () -> Void

    @State private var confirmNewLife = false
    @State private var showSettings = false

    // Terminal / game palette.
    private let bg = Color(red: 0.055, green: 0.075, blue: 0.10)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.72, blue: 0.34)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)
    private let panelGreen = Color(red: 0.13, green: 0.24, blue: 0.16)
    private let panelEdge = Color(red: 0.30, green: 0.50, blue: 0.32)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                HeroScene()
                    .frame(maxWidth: 460)
                    .padding(.horizontal, 10)
                    .padding(.top, 6)

                wordmark
                    .padding(.top, 14)

                Spacer(minLength: 8)

                controlBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }
        }
        .font(.system(.body, design: .monospaced))
        .alert("Start a new life?", isPresented: $confirmNewLife) {
            Button("Start over", role: .destructive) { Sound.tap(); onNewLife() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This erases your current save and begins a fresh freshman year.")
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(hasSave: $hasSave)
        }
    }

    // MARK: - Wordmark

    private var wordmark: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Text("💸").font(.system(size: 34))
                Text("FinLingo")
                    .font(.system(size: 42, weight: .heavy, design: .monospaced))
                    .foregroundColor(cream)
            }
            Text("build your money confidence")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(term)
        }
    }

    // MARK: - Control bar

    private var controlBar: some View {
        ZStack(alignment: .top) {
            // The button panel.
            HStack(spacing: 12) {
                sideButton(label: "LOAD GAME", enabled: hasSave) {
                    PixelFloppy().frame(width: 26, height: 26)
                } action: {
                    guard hasSave else { return }
                    Sound.tap(); onLoad()
                }

                Button {
                    if hasSave { confirmNewLife = true } else { Sound.tap(); onNewLife() }
                } label: {
                    Text("START NEW LIFE")
                        .font(.system(.headline, design: .monospaced).weight(.bold))
                        .foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(amber)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.35), lineWidth: 1))
                }
                .buttonStyle(.clicky)

                sideButton(label: "SETTINGS", enabled: true) {
                    PixelGear().frame(width: 26, height: 26)
                } action: {
                    Sound.tap(); showSettings = true
                }
            }
            .padding(14)
            .padding(.top, 8)
            .background(panelGreen)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(panelEdge, lineWidth: 2))

            // "a financial-literacy simulator" plate, straddling the top edge.
            Text("a financial-literacy simulator")
                .font(.system(.caption2, design: .monospaced).weight(.bold))
                .foregroundColor(cream.opacity(0.75))
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Color(red: 0.09, green: 0.14, blue: 0.10))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(panelEdge, lineWidth: 1.5))
                .offset(y: -11)
        }
    }

    private func sideButton<Icon: View>(label: String, enabled: Bool,
                                        @ViewBuilder icon: () -> Icon,
                                        action: @escaping () -> Void) -> some View {
        VStack(spacing: 5) {
            Button(action: action) {
                icon()
                    .frame(width: 58, height: 52)
                    .background(enabled ? panelEdge.opacity(0.9) : panelEdge.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(Color.black.opacity(0.35), lineWidth: 1))
            }
            .buttonStyle(.clicky)
            .disabled(!enabled)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(enabled ? cream.opacity(0.8) : cream.opacity(0.35))
        }
    }
}

// MARK: - Settings sheet

private struct SettingsSheet: View {
    @Binding var hasSave: Bool
    @ObservedObject private var music = MusicManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    private let bg = Color(red: 0.055, green: 0.075, blue: 0.10)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.72, blue: 0.34)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)
    private let red = Color(red: 0.86, green: 0.28, blue: 0.24)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                Text("SETTINGS")
                    .font(.system(.title2, design: .monospaced).weight(.heavy))
                    .foregroundColor(cream)

                Button { music.toggle() } label: {
                    HStack {
                        Image(systemName: music.isOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        Text("Ambient music")
                        Spacer()
                        Text(music.isOn ? "ON" : "OFF").foregroundColor(music.isOn ? term : cream.opacity(0.5))
                    }
                    .font(.system(.body, design: .monospaced).weight(.semibold))
                    .foregroundColor(cream)
                    .padding(14)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                if hasSave {
                    Button { confirmReset = true } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Erase save & progress")
                            Spacer()
                        }
                        .font(.system(.body, design: .monospaced).weight(.semibold))
                        .foregroundColor(red)
                        .padding(14)
                        .background(red.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Text("FinLingo — a financial-literacy simulator")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(cream.opacity(0.4))

                Button { dismiss() } label: {
                    Text("DONE")
                        .font(.system(.headline, design: .monospaced).weight(.bold))
                        .foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(amber)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.clicky)
            }
            .padding(22)
        }
        .alert("Erase everything?", isPresented: $confirmReset) {
            Button("Erase", role: .destructive) {
                PersistenceController.clear()
                hasSave = false
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This permanently deletes your save. You'll start fresh next time.")
        }
    }
}

// MARK: - The pixel hero scene (campus + framed dorm diorama + banner)

private struct HeroScene: View {
    // Logical pixel grid the art is authored in.
    private let gw: Double = 128
    private let gh: Double = 150

    var body: some View {
        Canvas { ctx, size in
            let s = Double(size.width) / gw
            drawSky(ctx, s)
            drawCampus(ctx, s)
            drawCrest(ctx, s)
            drawDorm(ctx, s)
            drawBannerPlate(ctx, s)
        }
        .aspectRatio(CGSize(width: gw, height: gh), contentMode: .fit)
        .overlay(alignment: .top) {
            // Banner text sits over the plate drawn in the canvas (≈ y 20–40 of 150).
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Text("LEVEL 1:")
                        .font(.system(size: max(9, geo.size.width * 0.045), weight: .heavy, design: .monospaced))
                        .foregroundColor(Color(red: 0.55, green: 0.80, blue: 0.52))
                    Text("FRESHMAN YEAR")
                        .font(.system(size: max(12, geo.size.width * 0.066), weight: .heavy, design: .monospaced))
                        .foregroundColor(Color(red: 0.68, green: 0.90, blue: 0.62))
                }
                .frame(width: geo.size.width)
                .position(x: geo.size.width / 2, y: geo.size.height * (30.0 / 150.0))
            }
        }
    }

    // MARK: pixel fill helpers

    private func r(_ ctx: GraphicsContext, _ s: Double, _ x: Double, _ y: Double, _ w: Double, _ h: Double, _ c: Color) {
        ctx.fill(Path(CGRect(x: x * s, y: y * s, width: w * s, height: h * s)), with: .color(c))
    }
    private func oval(_ ctx: GraphicsContext, _ s: Double, _ x: Double, _ y: Double, _ w: Double, _ h: Double, _ c: Color) {
        ctx.fill(Path(ellipseIn: CGRect(x: x * s, y: y * s, width: w * s, height: h * s)), with: .color(c))
    }

    // MARK: layers

    private func drawSky(_ ctx: GraphicsContext, _ s: Double) {
        r(ctx, s, 0, 0, gw, 20, Color(red: 0.49, green: 0.71, blue: 0.86))
        r(ctx, s, 0, 20, gw, 16, Color(red: 0.66, green: 0.83, blue: 0.93))
    }

    private func drawCampus(_ ctx: GraphicsContext, _ s: Double) {
        // Distant campus building + clock tower on the right.
        let stone = Color(red: 0.62, green: 0.46, blue: 0.36)
        let stoneHi = Color(red: 0.74, green: 0.57, blue: 0.44)
        let roof = Color(red: 0.36, green: 0.26, blue: 0.30)
        r(ctx, s, 90, 12, 30, 22, stone)
        r(ctx, s, 92, 14, 26, 4, stoneHi)
        r(ctx, s, 100, 4, 10, 10, stone)          // tower
        r(ctx, s, 101, 6, 8, 3, roof)
        r(ctx, s, 104, 8, 2, 3, Color(red: 0.9, green: 0.86, blue: 0.6)) // clock face
        // A low building on the left.
        r(ctx, s, 4, 18, 22, 16, stone)
        r(ctx, s, 5, 19, 20, 3, stoneHi)
        // Tree canopies across the horizon.
        let td = Color(red: 0.23, green: 0.42, blue: 0.24)
        let tm = Color(red: 0.32, green: 0.52, blue: 0.30)
        for i in 0..<9 {
            let x = Double(i) * 15 - 2
            oval(ctx, s, x, 20, 16, 14, i % 2 == 0 ? tm : td)
        }
        // Grass strip along the bottom of the sky band.
        r(ctx, s, 0, 32, gw, 12, Color(red: 0.30, green: 0.48, blue: 0.27))
        r(ctx, s, 54, 34, 20, 12, Color(red: 0.72, green: 0.63, blue: 0.44)) // path
    }

    private func drawCrest(_ ctx: GraphicsContext, _ s: Double) {
        // Shield outline (amber) then a slightly-inset dark fill.
        func shield(_ inset: Double) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: (12 + inset) * s, y: (24 + inset) * s))
            p.addLine(to: CGPoint(x: (116 - inset) * s, y: (24 + inset) * s))
            p.addLine(to: CGPoint(x: (116 - inset) * s, y: (120 - inset) * s))
            p.addLine(to: CGPoint(x: 64 * s, y: (142 - inset * 1.4) * s))
            p.addLine(to: CGPoint(x: (12 + inset) * s, y: (120 - inset) * s))
            p.closeSubpath()
            return p
        }
        ctx.fill(shield(0), with: .color(Color(red: 0.62, green: 0.47, blue: 0.22)))     // outer bronze
        ctx.fill(shield(2), with: .color(Color(red: 0.86, green: 0.68, blue: 0.34)))     // amber rim
        ctx.fill(shield(4), with: .color(Color(red: 0.07, green: 0.10, blue: 0.15)))     // dark interior
    }

    private func drawDorm(_ ctx: GraphicsContext, _ s: Double) {
        let wall = Color(red: 0.80, green: 0.70, blue: 0.52)
        let wallHi = Color(red: 0.88, green: 0.79, blue: 0.60)
        let wood = Color(red: 0.55, green: 0.36, blue: 0.21)
        let woodDk = Color(red: 0.37, green: 0.24, blue: 0.14)
        let woodHi = Color(red: 0.69, green: 0.49, blue: 0.30)

        // Back wall + floor (clipped visually by the dark crest around them).
        r(ctx, s, 18, 44, 92, 20, wall)
        r(ctx, s, 18, 44, 92, 2, wallHi)
        r(ctx, s, 18, 64, 92, 54, wood)
        for i in 0..<8 { r(ctx, s, 18, 64 + Double(i) * 7, 92, 1, woodDk.opacity(0.5)) } // planks

        // Window (left of center) + diploma (right).
        r(ctx, s, 40, 46, 18, 14, woodDk)
        r(ctx, s, 42, 48, 14, 10, Color(red: 0.53, green: 0.74, blue: 0.83))
        r(ctx, s, 48, 48, 1, 10, woodDk); r(ctx, s, 42, 52, 14, 1, woodDk)
        r(ctx, s, 92, 46, 13, 9, Color(red: 0.95, green: 0.90, blue: 0.72))
        r(ctx, s, 92, 46, 13, 9, .clear)
        ctx.stroke(Path(CGRect(x: 92 * s, y: 46 * s, width: 13 * s, height: 9 * s)), with: .color(Color(red: 0.86, green: 0.68, blue: 0.34)), lineWidth: 1)

        // Beds — blue (left), green (right).
        drawBed(ctx, s, x: 16, blanket: Color(red: 0.23, green: 0.35, blue: 0.49), hi: Color(red: 0.37, green: 0.51, blue: 0.64), woodDk: woodDk)
        drawBed(ctx, s, x: 90, blanket: Color(red: 0.26, green: 0.42, blue: 0.29), hi: Color(red: 0.44, green: 0.58, blue: 0.41), woodDk: woodDk)

        // Hanging lamp + light cone over the desk.
        r(ctx, s, 63, 44, 2, 9, woodDk)
        r(ctx, s, 59, 52, 10, 4, Color(red: 0.85, green: 0.64, blue: 0.30))
        var cone = Path()
        cone.move(to: CGPoint(x: 60 * s, y: 56 * s))
        cone.addLine(to: CGPoint(x: 68 * s, y: 56 * s))
        cone.addLine(to: CGPoint(x: 82 * s, y: 104 * s))
        cone.addLine(to: CGPoint(x: 46 * s, y: 104 * s))
        cone.closeSubpath()
        ctx.fill(cone, with: .color(Color(red: 1.0, green: 0.92, blue: 0.6).opacity(0.16)))

        // Desk.
        r(ctx, s, 44, 92, 40, 16, wood)
        r(ctx, s, 44, 92, 40, 3, woodHi)
        r(ctx, s, 46, 108, 4, 8, woodDk); r(ctx, s, 78, 108, 4, 8, woodDk)

        // The girl, seated at the desk.
        let hair = Color(red: 0.29, green: 0.18, blue: 0.16)
        let skin = Color(red: 0.76, green: 0.54, blue: 0.37)
        let top = Color(red: 0.44, green: 0.64, blue: 0.42)
        r(ctx, s, 56, 70, 16, 13, hair)          // hair
        r(ctx, s, 59, 74, 10, 8, skin)           // face
        r(ctx, s, 61, 77, 1.5, 1.5, hair); r(ctx, s, 65.5, 77, 1.5, 1.5, hair) // eyes
        r(ctx, s, 55, 83, 18, 9, top)            // torso
        r(ctx, s, 54, 85, 3, 6, skin); r(ctx, s, 71, 85, 3, 6, skin) // arms

        // Desk clutter: plant, papers, calculator, globe.
        r(ctx, s, 47, 84, 8, 6, woodHi)                                   // pot
        oval(ctx, s, 46, 76, 10, 9, Color(red: 0.33, green: 0.55, blue: 0.30)) // leaves
        r(ctx, s, 60, 96, 9, 5, Color(red: 0.95, green: 0.90, blue: 0.72))     // papers
        r(ctx, s, 70, 94, 6, 7, Color(red: 0.16, green: 0.18, blue: 0.22))     // calculator
        r(ctx, s, 71, 95, 4, 2, Color(red: 0.5, green: 0.7, blue: 0.6))        // calc screen
        oval(ctx, s, 76, 84, 9, 9, Color(red: 0.28, green: 0.50, blue: 0.74))  // globe
        oval(ctx, s, 78, 86, 3, 3, Color(red: 0.45, green: 0.66, blue: 0.85))
        r(ctx, s, 80, 92, 1.5, 4, woodDk)

        // Skateboard on the floor, right.
        r(ctx, s, 88, 112, 18, 3, Color(red: 0.72, green: 0.34, blue: 0.30))
        oval(ctx, s, 90, 114, 3, 3, Color(red: 0.2, green: 0.2, blue: 0.2))
        oval(ctx, s, 101, 114, 3, 3, Color(red: 0.2, green: 0.2, blue: 0.2))

        // Stack of gold coins, bottom-left.
        drawCoins(ctx, s)
    }

    private func drawBed(_ ctx: GraphicsContext, _ s: Double, x: Double, blanket: Color, hi: Color, woodDk: Color) {
        r(ctx, s, x, 66, 22, 42, woodDk)
        r(ctx, s, x + 2, 72, 18, 34, blanket)
        r(ctx, s, x + 2, 72, 18, 5, hi)
        r(ctx, s, x + 3, 67, 16, 6, Color(red: 0.95, green: 0.90, blue: 0.72)) // pillow
    }

    private func drawCoins(_ ctx: GraphicsContext, _ s: Double) {
        let gold = Color(red: 0.90, green: 0.74, blue: 0.30)
        let goldDk = Color(red: 0.74, green: 0.55, blue: 0.20)
        let goldHi = Color(red: 1.0, green: 0.88, blue: 0.52)
        // Two short stacks + one tall.
        func stack(_ bx: Double, _ count: Int) {
            for i in 0..<count {
                let y = 116 - Double(i) * 3.4
                oval(ctx, s, bx, y, 15, 5, i == count - 1 ? goldHi : gold)
                oval(ctx, s, bx, y, 15, 5, .clear)
                ctx.stroke(Path(ellipseIn: CGRect(x: bx * s, y: y * s, width: 15 * s, height: 5 * s)), with: .color(goldDk), lineWidth: 0.6)
            }
            // $ on the top coin.
            let ty = 116 - Double(count - 1) * 3.4
            r(ctx, s, bx + 6.7, ty + 0.6, 1.2, 3.6, goldDk)
            r(ctx, s, bx + 5.5, ty + 1.2, 3.6, 1.0, goldDk)
            r(ctx, s, bx + 5.5, ty + 2.8, 3.6, 1.0, goldDk)
        }
        stack(22, 5)
        stack(30, 3)
    }

    private func drawBannerPlate(_ ctx: GraphicsContext, _ s: Double) {
        // A dark-green banner plate with an amber frame, overlapping the crest top.
        r(ctx, s, 22, 18, 84, 24, Color(red: 0.62, green: 0.47, blue: 0.22))
        r(ctx, s, 24, 20, 80, 20, Color(red: 0.09, green: 0.20, blue: 0.13))
        r(ctx, s, 25, 21, 78, 2, Color(red: 0.86, green: 0.68, blue: 0.34).opacity(0.5))
        // little end tabs
        r(ctx, s, 18, 24, 6, 10, Color(red: 0.55, green: 0.41, blue: 0.20))
        r(ctx, s, 104, 24, 6, 10, Color(red: 0.55, green: 0.41, blue: 0.20))
    }
}

// MARK: - Small pixel icons for the side buttons

private struct PixelFloppy: View {
    var body: some View {
        Canvas { ctx, size in
            let s = Double(size.width) / 24
            func r(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ c: Color) {
                ctx.fill(Path(CGRect(x: x * s, y: y * s, width: w * s, height: h * s)), with: .color(c))
            }
            let body = Color(red: 0.10, green: 0.13, blue: 0.18)
            let metal = Color(red: 0.62, green: 0.66, blue: 0.72)
            let label = Color(red: 0.96, green: 0.90, blue: 0.70)
            r(3, 3, 18, 18, body)
            r(6, 3, 9, 6, metal)          // slider
            r(11, 4, 2, 4, body)          // slider notch
            r(6, 12, 12, 9, label)        // label
            r(8, 14, 8, 1.4, body); r(8, 16.5, 8, 1.4, body)
        }
    }
}

private struct PixelGear: View {
    var body: some View {
        Canvas { ctx, size in
            let s = Double(size.width) / 24
            func r(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ c: Color) {
                ctx.fill(Path(CGRect(x: x * s, y: y * s, width: w * s, height: h * s)), with: .color(c))
            }
            let g = Color(red: 0.10, green: 0.13, blue: 0.18)
            // teeth
            r(10, 2, 4, 4, g); r(10, 18, 4, 4, g); r(2, 10, 4, 4, g); r(18, 10, 4, 4, g)
            r(5, 5, 3, 3, g); r(16, 5, 3, 3, g); r(5, 16, 3, 3, g); r(16, 16, 3, 3, g)
            // hub
            ctx.fill(Path(ellipseIn: CGRect(x: 6 * s, y: 6 * s, width: 12 * s, height: 12 * s)), with: .color(g))
            ctx.fill(Path(ellipseIn: CGRect(x: 10 * s, y: 10 * s, width: 4 * s, height: 4 * s)), with: .color(Color(red: 0.30, green: 0.50, blue: 0.32)))
        }
    }
}
