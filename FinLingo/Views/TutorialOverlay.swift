//
//  TutorialOverlay.swift
//  FinLingo
//
//  A one-time coach tour shown right after onboarding. The screen dims, the pixel character is
//  brought to the front, and it hops between the three key spots — the Learn laptop, the
//  Simulator laptop, and the Shop — with a short explanation of each, then a send-off.
//

import SwiftUI

private struct TutorialStep {
    let title: String
    let body: String
    /// Where the character + highlight ring sit, as a fraction of the screen. nil = centered,
    /// no ring (used for the closing "you're all set" beat).
    let spot: UnitPoint?
}

struct TutorialOverlay: View {
    let playerName: String
    var onFinish: () -> Void

    @State private var index = 0
    @State private var ringPulse = false

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
                body: "\(hi) That laptop on the left is where you learn — bite-size money lessons on budgeting, investing, and credit. Every question you get right pays real cash into your account.",
                spot: UnitPoint(x: 0.30, y: 0.40)
            ),
            TutorialStep(
                title: "② SIMULATE",
                body: "The laptop on the right is your practice sandbox. Trade real market history, project a 401(k), plan a debt payoff, and meet your Future You — all with zero risk.",
                spot: UnitPoint(x: 0.70, y: 0.40)
            ),
            TutorialStep(
                title: "③ SHOP",
                body: "Down here is the Shop. Soon you'll deck out your dorm — posters, plants, string lights, even a pet — to make the place feel like home.",
                spot: UnitPoint(x: 0.84, y: 0.92)
            ),
            TutorialStep(
                title: "YOU'RE ALL SET",
                body: "That's the grand tour! Explore, tap around, and start building your money life. Have fun — now go make some money! 💸",
                spot: nil
            ),
        ]
    }

    private var step: TutorialStep { steps[min(index, steps.count - 1)] }
    private var isLast: Bool { index >= steps.count - 1 }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dim the whole game behind the tour.
                Color.black.opacity(0.72).ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { advance() }

                if let spot = step.spot {
                    characterMarker
                        .position(x: geo.size.width * spot.x, y: geo.size.height * spot.y)
                        .transition(.opacity)
                        .id(index) // re-run the entrance each step
                }

                VStack {
                    // Skip in the corner.
                    HStack {
                        Spacer()
                        Button { onFinish() } label: {
                            Text("SKIP")
                                .font(.system(.caption, design: .monospaced).weight(.bold))
                                .foregroundColor(dim)
                                .padding(10)
                        }
                    }
                    Spacer()
                    if step.spot == nil { centeredCharacter }
                    Spacer()
                    card
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .animation(.easeInOut(duration: 0.35), value: index)
        }
        .font(.system(.body, design: .monospaced))
        .onAppear { ringPulse = true }
    }

    // The character with a pulsing highlight ring, shown at a step's spot.
    private var characterMarker: some View {
        ZStack {
            Circle()
                .stroke(amber.opacity(0.9), lineWidth: 3)
                .frame(width: 96, height: 96)
                .scaleEffect(ringPulse ? 1.12 : 0.92)
                .opacity(ringPulse ? 0.5 : 1)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: ringPulse)
            characterSprite
        }
    }

    // Character standing on its own for the closing beat.
    private var centeredCharacter: some View {
        characterSprite.scaleEffect(1.15)
    }

    private var characterSprite: some View {
        Image(uiImage: PixelArtStyle.pixelArtImage(named: "player_down_idle", size: CGSize(width: 18, height: 26)))
            .resizable()
            .interpolation(.none)
            .frame(width: 45, height: 65)
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

    private func advance() {
        if isLast {
            onFinish()
        } else {
            index += 1
        }
    }
}
