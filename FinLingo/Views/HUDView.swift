//
//  HUDView.swift
//  FinLingo
//
//  Compact, non-interactive top status bar (design §4).
//

import SwiftUI

/// A compact heads-up display pinned to the top-leading corner. Informational only —
/// disables hit testing so taps pass through to the game scene below.
struct HUDView: View {

    @ObservedObject var gameState: GameState
    @ObservedObject var economy: EconomyEngine
    @ObservedObject var stageController: StageController

    private let pillBackground = Color.black.opacity(0.55)
    private let accentCream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let accentAmber = Color(red: 0.95, green: 0.65, blue: 0.20)

    private var isDanger: Bool { economy.heat >= 90 || economy.isOverheated }

    /// The next stage's name + unlock price, or nil if already on the last stage.
    private var nextUnlock: (name: String, price: Int)? {
        let nextIndex = gameState.currentStageIndex + 1
        guard nextIndex < stageController.stages.count else { return nil }
        let stage = stageController.stages[nextIndex]
        return (stage.displayName, stage.unlockPrice)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Text(gameState.companyName)
                    .foregroundColor(accentCream)
                    .lineLimit(1)
                Text(CurrencyFormat.short(gameState.cash))
                    .foregroundColor(accentAmber)
            }
            .font(.system(.subheadline, design: .monospaced).weight(.bold))

            HStack(spacing: 12) {
                Text("\(NumberFormatShort.short(economy.computePerSec)) c/s")
                    .foregroundColor(.green.opacity(0.85))
                Text(CurrencyFormat.perSecond(economy.cashPerSec))
                    .foregroundColor(accentCream.opacity(0.85))
            }
            .font(.system(.caption, design: .monospaced))

            unlockProgress
            heatIndicator
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(pillBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .allowsHitTesting(false)
    }

    // MARK: - Unlock progress

    @ViewBuilder
    private var unlockProgress: some View {
        if let next = nextUnlock {
            VStack(alignment: .leading, spacing: 2) {
                let unlocked = stageController.isUnlocked(gameState.currentStageIndex + 1)
                Text(unlocked ? "\(next.name): unlocked — walk through the door ↓"
                              : "Next: \(next.name)  \(CurrencyFormat.short(gameState.cash))/\(CurrencyFormat.short(next.price))")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(unlocked ? .green.opacity(0.9) : accentCream.opacity(0.8))
                    .lineLimit(1)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.15))
                        Capsule()
                            .fill(unlocked ? Color.green : accentAmber)
                            .frame(width: geo.size.width * progressFraction(price: next.price, unlocked: unlocked))
                    }
                }
                .frame(width: 120, height: 4)
            }
        }
    }

    private func progressFraction(price: Int, unlocked: Bool) -> CGFloat {
        if unlocked || price <= 0 { return 1 }
        return CGFloat(min(max(gameState.cash / Double(price), 0), 1))
    }

    // MARK: - Heat bar

    private var heatIndicator: some View {
        VStack(alignment: .leading, spacing: 2) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.15))
                    Capsule()
                        .fill(isDanger ? Color.red : accentAmber)
                        .frame(width: geo.size.width * CGFloat(min(max(economy.heat / 100, 0), 1)))
                }
            }
            .frame(width: 120, height: 5)

            if economy.isOverheated {
                Text("OVERHEATED")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
            }
        }
    }
}
