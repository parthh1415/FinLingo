import Combine
import SwiftUI

/// A dedicated bottom-screen control for the overclock mechanic. Press and hold to keep
/// tapping the rig (each tick adds heat → higher compute multiplier); release to let it cool.
/// Replaces the old "tap the GPU sprites on the map" interaction.
///
/// Only shown once the player owns at least one piece of gear (nothing to overclock otherwise).
struct OverclockButton: View {
    @ObservedObject var economy: EconomyEngine
    @ObservedObject var gameState: GameState

    @State private var isPressing = false
    @State private var repeatTimer: Timer?

    // Palette (game colors).
    private let cream = Color(red: 0.95, green: 0.89, blue: 0.77)
    private let amber = Color(red: 0.83, green: 0.66, blue: 0.33)
    private let danger = Color(red: 0.86, green: 0.28, blue: 0.24)
    private let panel = Color(red: 0.10, green: 0.09, blue: 0.11)

    private var heatFraction: CGFloat { CGFloat(min(max(economy.heat / 100, 0), 1)) }
    private var fillColor: Color { economy.isOverheated ? danger : amber }

    var body: some View {
        if gameState.ownsAnyGear {
            button
        }
    }

    private var button: some View {
        VStack(spacing: 6) {
            // Multiplier + status line
            HStack {
                Text("OVERCLOCK")
                    .foregroundColor(economy.isOverheated ? danger : cream)
                Spacer()
                Text(economy.isOverheated ? "OVERHEATED" : String(format: "%.1f×", economy.boostMultiplier))
                    .foregroundColor(economy.isOverheated ? danger : amber)
                    .monospacedDigit()
            }
            .font(.system(.subheadline, design: .monospaced).weight(.bold))

            // Heat gauge
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(fillColor)
                        .frame(width: geo.size.width * heatFraction)
                    // redline marker at 90%
                    Rectangle()
                        .fill(danger.opacity(0.8))
                        .frame(width: 2)
                        .offset(x: geo.size.width * 0.9)
                }
            }
            .frame(height: 8)
            // make the learning curve more undesrtandable
            Text(economy.isOverheated ? "cooling down…" : "hold to overclock")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(cream.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: 240)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(panel.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke((economy.isOverheated ? danger : amber).opacity(0.7), lineWidth: 2)
                )
        )
        .scaleEffect(isPressing ? 0.96 : 1.0)
        .animation(.easeOut(duration: 0.08), value: isPressing)
        .shadow(color: (economy.isOverheated ? danger : amber).opacity(isPressing ? 0.5 : 0.25),
                radius: isPressing ? 14 : 8)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isPressing { beginPressing() } }
                .onEnded { _ in endPressing() }
        )
        .onDisappear { endPressing() }
        .accessibilityLabel("Overclock")
        .accessibilityHint("Hold to raise heat and boost compute. Overheats past the redline.")
    }

    private func beginPressing() {
        isPressing = true
        economy.registerTap()
        repeatTimer?.invalidate()
        repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.11, repeats: true) { _ in
            economy.registerTap()
        }
    }

    private func endPressing() {
        isPressing = false
        repeatTimer?.invalidate()
        repeatTimer = nil
    }
}
