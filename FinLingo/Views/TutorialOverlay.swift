//
//  TutorialOverlay.swift
//  FinLingo
//
//  A one-time coach tour shown right after onboarding. The screen dims and the pixel character
//  stands at the bottom-left, turning to point an arrow at each place the player can go — the
//  Learn laptop, the Simulator laptop, and the Shop — then a send-off.
//

import SwiftUI

private struct TutorialStep {
    let title: String
    let body: String
    /// Where the arrow points, as a fraction of the screen. nil = no arrow (closing beat).
    let target: UnitPoint?
    /// Which way the character faces this step: "up" / "down" / "left" / "right".
    let facing: String
}

/// A dashed line with an arrowhead, drawn in absolute screen coordinates (its frame is the
/// whole screen). Animatable so it glides as the target changes between steps.
private struct ArrowLine: Shape {
    var from: CGPoint
    var to: CGPoint

    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(AnimatablePair(from.x, from.y), AnimatablePair(to.x, to.y)) }
        set {
            from = CGPoint(x: newValue.first.first, y: newValue.first.second)
            to = CGPoint(x: newValue.second.first, y: newValue.second.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: from)
        p.addLine(to: to)
        let angle = atan2(to.y - from.y, to.x - from.x)
        let headLen: CGFloat = 15
        let spread = CGFloat.pi / 7
        p.move(to: CGPoint(x: to.x - headLen * cos(angle - spread), y: to.y - headLen * sin(angle - spread)))
        p.addLine(to: to)
        p.addLine(to: CGPoint(x: to.x - headLen * cos(angle + spread), y: to.y - headLen * sin(angle + spread)))
        return p
    }
}

struct TutorialOverlay: View {
    let playerName: String
    var onFinish: () -> Void

    @State private var index = 0
    @State private var pulse = false

    /// The character's fixed home: lower-left of the screen.
    private let charSpot = UnitPoint(x: 0.24, y: 0.70)

    // Terminal palette, matching the rest of the game's screens.
    private let screen = Color(red: 0.055, green: 0.075, blue: 0.09)
    private let edge = Color(red: 0.83, green: 0.66, blue: 0.33)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)
    private var dim: Color { cream.opacity(0.45) }

    private var steps: [TutorialStep] {
        let hi = playerName.isEmpty ? "Welcome home!" : "Hey \(playerName)! Welcome home."
        return [
            TutorialStep(
                title: "① LEARN",
                body: "\(hi) The laptop on the left is where you learn — bite-size money lessons on budgeting, investing, and credit. Every question you get right pays real cash into your account.",
                target: UnitPoint(x: 0.40, y: 0.42), facing: "up"
            ),
            TutorialStep(
                title: "② SIMULATE",
                body: "The laptop on the right is your practice sandbox. Trade real market history, project a 401(k) or a 529, plan a debt payoff, and meet your Future You — all with zero risk.",
                target: UnitPoint(x: 0.62, y: 0.44), facing: "right"
            ),
            TutorialStep(
                title: "③ SHOP",
                body: "Down in the corner is the Shop. Deck out your dorm — posters, plants, string lights — and adopt a pet that follows you around to make the place feel like home.",
                target: UnitPoint(x: 0.84, y: 0.93), facing: "right"
            ),
            TutorialStep(
                title: "④ REAL LIFE",
                body: "That's the tour! Now life happens — money decisions pop up as time passes, starting right now. Handle them well and watch your net worth climb. Ready for your first one? 💸",
                target: nil, facing: "down"
            ),
        ]
    }

    private var step: TutorialStep { steps[min(index, steps.count - 1)] }
    private var isLast: Bool { index >= steps.count - 1 }

    var body: some View {
        GeometryReader { geo in
            let charPt = CGPoint(x: geo.size.width * charSpot.x, y: geo.size.height * charSpot.y)

            ZStack(alignment: .topLeading) {
                // Dim the whole game behind the tour; a tap anywhere advances it.
                Color.black.opacity(0.72).ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { advance() }

                // Arrow + pulsing ring pointing at the current place.
                if let target = step.target {
                    let targetPt = CGPoint(x: geo.size.width * target.x, y: geo.size.height * target.y)
                    let start = point(from: charPt, toward: targetPt, distance: 42)
                    let end = point(from: targetPt, toward: charPt, distance: 30)

                    ArrowLine(from: start, to: end)
                        .stroke(amber, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [7, 5]))
                        .frame(width: geo.size.width, height: geo.size.height)
                        .opacity(pulse ? 1 : 0.55)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)

                    Circle()
                        .stroke(amber.opacity(0.9), lineWidth: 3)
                        .frame(width: 56, height: 56)
                        .scaleEffect(pulse ? 1.15 : 0.9)
                        .opacity(pulse ? 0.5 : 1)
                        .position(targetPt)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
                }

                // The coach stays put at the lower-left, just turning to face each place.
                characterSprite(facing: step.facing)
                    .position(charPt)

                // Text card + skip, kept up top so the lower half stays clear for the pointing.
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        Button { onFinish() } label: {
                            Text("SKIP")
                                .font(.system(.caption, design: .monospaced).weight(.bold))
                                .foregroundColor(dim)
                                .padding(8)
                        }
                    }
                    card
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .animation(.easeInOut(duration: 0.35), value: index)
        }
        .font(.system(.body, design: .monospaced))
        .onAppear { pulse = true }
    }

    private func characterSprite(facing: String) -> some View {
        Image(uiImage: PixelArtStyle.pixelArtImage(named: "player_\(facing)_idle", size: CGSize(width: 18, height: 26)))
            .resizable()
            .interpolation(.none)
            .frame(width: 48, height: 70)
            .shadow(color: .black.opacity(0.5), radius: 6, y: 3)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(step.title)
                .font(.system(.caption, design: .monospaced).weight(.bold))
                .foregroundColor(term)
            Text(step.body)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(cream)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                progressDots
                Spacer()
                Button { advance() } label: {
                    Text(isLast ? "LET'S GO" : "NEXT")
                        .font(.system(.subheadline, design: .monospaced).weight(.bold))
                        .foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
                        .padding(.horizontal, 22).frame(minHeight: 44)
                        .background(amber)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.clicky)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(screen)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(edge.opacity(0.75), lineWidth: 2))
        .shadow(color: edge.opacity(0.25), radius: 22, y: 10)
    }

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(steps.indices, id: \.self) { i in
                Circle()
                    .fill(i == index ? amber : dim.opacity(0.5))
                    .frame(width: 7, height: 7)
            }
        }
    }

    /// A point `distance` pixels from `a` along the line toward `b`.
    private func point(from a: CGPoint, toward b: CGPoint, distance: CGFloat) -> CGPoint {
        let dx = b.x - a.x, dy = b.y - a.y
        let len = max(hypot(dx, dy), 0.0001)
        return CGPoint(x: a.x + dx / len * distance, y: a.y + dy / len * distance)
    }

    private func advance() {
        if isLast {
            onFinish()
        } else {
            index += 1
        }
    }
}
