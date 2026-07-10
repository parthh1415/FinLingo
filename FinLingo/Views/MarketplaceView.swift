//
//  MarketplaceView.swift
//  FinLingo
//
//  The in-game computer screen: a terminal-styled modal for buying GPUs (design §8).
//

import SwiftUI

/// A terminal/computer-screen modal that lets the player buy gear for the current stage.
struct MarketplaceView: View {

    @ObservedObject var gameState: GameState
    @ObservedObject var economy: EconomyEngine

    /// Invoked when the player taps Close or the dimmed scrim.
    var onClose: () -> Void

    // MARK: - Palette
    private let scrim = Color.black.opacity(0.6)
    private let screen = Color(red: 0.055, green: 0.075, blue: 0.09)   // deep terminal screen
    private let screenEdge = Color(red: 0.83, green: 0.66, blue: 0.33) // amber bezel
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)       // terminal green
    private let dim = Color(red: 0.96, green: 0.90, blue: 0.70).opacity(0.45)

    var body: some View {
        ZStack {
            scrim
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onClose() }

            screenCard
                .padding(.horizontal, 20)
        }
        .font(.system(.body, design: .monospaced))
    }

    // MARK: - Screen

    private var screenCard: some View {
        VStack(spacing: 0) {
            titleBar
            statusLine
            Rectangle().fill(screenEdge.opacity(0.35)).frame(height: 1)
            gearList
            Rectangle().fill(screenEdge.opacity(0.35)).frame(height: 1)
            footer
        }
        .background(screen)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(screenEdge.opacity(0.75), lineWidth: 2)
        )
        .shadow(color: screenEdge.opacity(0.25), radius: 22, y: 10)
        .contentShape(Rectangle())
        .onTapGesture { /* absorb taps inside the screen */ }
    }

    private var titleBar: some View {
        HStack(alignment: .center, spacing: 10) {
            // terminal window dots
            HStack(spacing: 5) {
                Circle().fill(Color(red: 0.86, green: 0.28, blue: 0.24)).frame(width: 9, height: 9)
                Circle().fill(amber).frame(width: 9, height: 9)
                Circle().fill(term).frame(width: 9, height: 9)
            }
            Text("shop.finlingo")
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(dim)
            Spacer()
            Text(CurrencyFormat.short(gameState.cash))
                .font(.system(.headline, design: .monospaced).weight(.bold))
                .foregroundColor(amber)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    private var statusLine: some View {
        HStack(spacing: 6) {
            Text(">")
                .foregroundColor(term)
            Text("\(economy.currentStage.displayName.uppercased()) — upgrades that pay you")
                .foregroundColor(term.opacity(0.9))
            Spacer()
        }
        .font(.system(.caption, design: .monospaced))
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var gearList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(economy.currentStage.gearCatalog) { gear in
                    gearRow(gear)
                }
            }
            .padding(16)
        }
        .frame(maxHeight: 400)
    }

    private func gearRow(_ gear: GearDefinition) -> some View {
        let affordable = economy.canAfford(gear)
        let owned = gameState.ownedCount(of: gear.id)
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(gear.displayName)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(cream)
                    if owned > 0 {
                        Text("×\(owned)")
                            .font(.system(.caption, design: .monospaced).weight(.bold))
                            .foregroundColor(amber)
                            .monospacedDigit()
                    }
                }
                Text("+\(CurrencyFormat.short(gear.computePerSecond * economy.currentStage.computeToCashRate))/s income")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(term)
            }

            Spacer(minLength: 8)

            Button {
                economy.purchase(gear)
            } label: {
                VStack(spacing: 1) {
                    Text("BUY")
                        .font(.system(.caption2, design: .monospaced).weight(.bold))
                    Text(CurrencyFormat.short(gear.cost))
                        .font(.system(.subheadline, design: .monospaced).weight(.bold))
                        .monospacedDigit()
                }
                .frame(minWidth: 92, minHeight: 44)
                .background(affordable ? amber : Color.white.opacity(0.06))
                .foregroundColor(affordable ? Color(red: 0.06, green: 0.08, blue: 0.09) : dim)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .disabled(!affordable)
        }
        .padding(12)
        .background(Color.white.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var footer: some View {
        Button {
            onClose()
        } label: {
            Text("CLOSE")
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(cream)
                .frame(maxWidth: .infinity, minHeight: 48)
        }
    }
}
