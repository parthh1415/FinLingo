//
//  MarketplaceView.swift
//  FinLingo
//
//  The in-game computer screen: a terminal-styled shop for decorating your space. For now the
//  catalog is a preview — every item (and the pet) is listed as "coming soon" until the
//  decoration system ships.
//

import SwiftUI

/// One shop item shown in the decoration catalog. Purely cosmetic for now — nothing is
/// purchasable yet, so there's no cost or economy hook.
private struct ShopItem: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let blurb: String
    let tag: String   // "DECOR" or "PET"
}

/// A terminal/computer-screen modal previewing the room-decoration shop.
struct MarketplaceView: View {

    @ObservedObject var gameState: GameState
    @ObservedObject var economy: EconomyEngine

    /// Invoked when the player taps Close or the dimmed scrim.
    var onClose: () -> Void

    /// What the one purchasable item — the pet — costs in cash.
    private let petCost: Double = 1500

    // MARK: - Catalog (the pet is buyable; everything else is a preview)

    private let catalog: [ShopItem] = [
        ShopItem(icon: "🐾", name: "Pet companion", blurb: "Adopt a little buddy to keep you company.", tag: "PET"),
        ShopItem(icon: "🪧", name: "Wall posters", blurb: "Framed art to show off your style.", tag: "DECOR"),
        ShopItem(icon: "✨", name: "String lights", blurb: "Warm fairy lights to cozy up the walls.", tag: "DECOR"),
        ShopItem(icon: "🪴", name: "Potted plants", blurb: "A little green to make it feel alive.", tag: "DECOR"),
        ShopItem(icon: "🧸", name: "Bean bag chair", blurb: "The comfiest spot to unwind.", tag: "DECOR"),
        ShopItem(icon: "🛋️", name: "Cozy rug", blurb: "Soften the floor underfoot.", tag: "DECOR"),
        ShopItem(icon: "💡", name: "Desk lamp", blurb: "Soft light for late-night study.", tag: "DECOR"),
        ShopItem(icon: "📚", name: "Bookshelf", blurb: "Fill it with your favorites.", tag: "DECOR"),
        ShopItem(icon: "❄️", name: "Mini fridge", blurb: "Snacks within arm's reach.", tag: "DECOR"),
    ]

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
            itemList
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
            Text("\(economy.currentStage.displayName.uppercased()) — upgrades to make it feel homey")
                .foregroundColor(term.opacity(0.9))
            Spacer()
        }
        .font(.system(.caption, design: .monospaced))
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var itemList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(catalog) { item in
                    itemRow(item)
                }
            }
            .padding(16)
        }
        .frame(maxHeight: 400)
    }

    private func itemRow(_ item: ShopItem) -> some View {
        HStack(spacing: 12) {
            Text(item.icon)
                .font(.system(size: 26))

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(item.name)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(cream)
                    Text(item.tag)
                        .font(.system(.caption2, design: .monospaced).weight(.bold))
                        .foregroundColor(item.tag == "PET" ? amber : term)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background((item.tag == "PET" ? amber : term).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                Text(item.blurb)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(dim)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            // The pet can actually be adopted; every other item is still a preview.
            if item.tag == "PET" {
                petAction
            } else {
                Text("COMING\nSOON")
                    .font(.system(.caption2, design: .monospaced).weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(dim)
                    .frame(minWidth: 92, minHeight: 44)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    /// The pet's buy button — or an OWNED badge once it's been adopted.
    @ViewBuilder
    private var petAction: some View {
        if gameState.hasPet {
            Text("OWNED ✓")
                .font(.system(.caption2, design: .monospaced).weight(.bold))
                .foregroundColor(term)
                .frame(minWidth: 92, minHeight: 44)
                .background(term.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            let affordable = gameState.cash >= petCost
            Button { buyPet() } label: {
                VStack(spacing: 1) {
                    Text("ADOPT")
                        .font(.system(.caption2, design: .monospaced).weight(.bold))
                    Text(CurrencyFormat.short(petCost))
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
    }

    private func buyPet() {
        guard !gameState.hasPet, gameState.cash >= petCost else { return }
        Sound.tap()
        gameState.cash -= petCost
        gameState.hasPet = true
        PersistenceController.save(gameState)
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
