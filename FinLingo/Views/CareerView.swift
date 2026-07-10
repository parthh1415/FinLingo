//
//  CareerView.swift
//  FinLingo
//
//  Opened from the INCOME chip in the HUD. Two ways to grow the number that drives the
//  whole economy: win a one-time salary negotiation, and take on side hustles bought with
//  cash. Both permanently raise monthly income — money tied to career growth.
//

import SwiftUI

struct SideHustle: Identifiable {
    let id: String
    let name: String
    let cost: Double
    let monthlyBoost: Double
}

enum CareerContent {
    static let hustles: [SideHustle] = [
        SideHustle(id: "crafts", name: "Sell crafts online", cost: 600, monthlyBoost: 150),
        SideHustle(id: "tutoring", name: "Weekend tutoring", cost: 1500, monthlyBoost: 300),
        SideHustle(id: "freelance", name: "Freelance design", cost: 3500, monthlyBoost: 600),
        SideHustle(id: "content", name: "Content creator", cost: 8000, monthlyBoost: 1200),
    ]

    // A quick negotiation check — the research-backed counter is the right move.
    static let raiseAmount: Double = 500
    static let negotiationQuestion = "Your manager offers a 2% raise. What's the strongest move?"
    static let negotiationOptions = [
        "Take it — asking for more is rude",
        "Counter with a specific number backed by market research",
        "Threaten to quit on the spot",
    ]
    static let negotiationCorrect = 1
}

struct CareerView: View {
    @ObservedObject var gameState: GameState
    var onClose: () -> Void

    @State private var negotiationPick: Int?

    private let screen = Color(red: 0.055, green: 0.075, blue: 0.09)
    private let edge = Color(red: 0.83, green: 0.66, blue: 0.33)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)
    private let red = Color(red: 0.86, green: 0.28, blue: 0.24)
    private var dim: Color { cream.opacity(0.45) }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea().contentShape(Rectangle()).onTapGesture { onClose() }

            VStack(spacing: 0) {
                titleBar
                Rectangle().fill(edge.opacity(0.35)).frame(height: 1)
                content
                Rectangle().fill(edge.opacity(0.35)).frame(height: 1)
                footer
            }
            .background(screen)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(edge.opacity(0.75), lineWidth: 2))
            .contentShape(Rectangle()).onTapGesture { }
            .padding(.horizontal, 20)
        }
        .font(.system(.body, design: .monospaced))
    }

    private var titleBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 5) {
                Circle().fill(red).frame(width: 9, height: 9)
                Circle().fill(amber).frame(width: 9, height: 9)
                Circle().fill(term).frame(width: 9, height: 9)
            }
            Text("career.finlingo").font(.system(.footnote, design: .monospaced)).foregroundColor(dim)
            Spacer()
            Text("\(CurrencyFormat.short(gameState.monthlyIncome))/mo")
                .font(.system(.headline, design: .monospaced).weight(.bold)).foregroundColor(amber).monospacedDigit()
        }
        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
    }

    // Shows the player's real job + salary; raises and hustles grow this number.
    private var jobHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(gameState.jobTitle.isEmpty ? "YOUR ROLE" : gameState.jobTitle.uppercased())
                .font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(term)
            Text("\(gameState.playerName.isEmpty ? "You" : gameState.playerName) · \(CurrencyFormat.short(gameState.monthlyIncome))/mo · \(CurrencyFormat.short(gameState.monthlyIncome * 12))/yr")
                .font(.system(.subheadline, design: .monospaced)).foregroundColor(cream)
            Text("Every raise and side hustle below builds on your real salary.")
                .font(.system(.caption, design: .monospaced)).foregroundColor(dim)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                jobHeader
                negotiationCard
                Text("> side hustles").font(.system(.caption, design: .monospaced)).foregroundColor(term)
                ForEach(CareerContent.hustles) { hustle in hustleRow(hustle) }
            }
            .padding(16)
        }
        .frame(maxHeight: 460)
    }

    private var negotiationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NEGOTIATE A RAISE").font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(term)
            if gameState.negotiationDone {
                Text("Raise secured — +\(CurrencyFormat.short(CareerContent.raiseAmount))/mo. Nicely done.")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(dim)
            } else {
                Text(CareerContent.negotiationQuestion).font(.system(.subheadline, design: .monospaced)).foregroundColor(cream)
                ForEach(CareerContent.negotiationOptions.indices, id: \.self) { i in
                    Button { negotiate(i) } label: {
                        HStack {
                            Text(CareerContent.negotiationOptions[i]).font(.system(.caption, design: .monospaced)).foregroundColor(cream).multilineTextAlignment(.leading)
                            Spacer()
                            if let negotiationPick, negotiationPick == i {
                                Text(i == CareerContent.negotiationCorrect ? "✓" : "✗").foregroundColor(i == CareerContent.negotiationCorrect ? term : red)
                            }
                        }
                        .padding(10).background(negotiationBackground(i))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain).disabled(negotiationPick != nil)
                }
                if let negotiationPick {
                    Text(negotiationPick == CareerContent.negotiationCorrect
                         ? "Correct! +\(CurrencyFormat.short(CareerContent.raiseAmount))/mo raise."
                         : "That leaves money on the table — a researched counter is the move.")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(negotiationPick == CareerContent.negotiationCorrect ? term : dim)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }

    private func hustleRow(_ hustle: SideHustle) -> some View {
        let owned = gameState.sideHustles.contains(hustle.id)
        let affordable = gameState.cash >= hustle.cost
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(hustle.name).font(.system(.subheadline, design: .monospaced)).foregroundColor(cream)
                Text("+\(CurrencyFormat.short(hustle.monthlyBoost))/mo").font(.system(.caption, design: .monospaced)).foregroundColor(term)
            }
            Spacer(minLength: 8)
            if owned {
                Text("ACTIVE ✓").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(term)
            } else {
                Button { buy(hustle) } label: {
                    VStack(spacing: 1) {
                        Text("START").font(.system(.caption2, design: .monospaced).weight(.bold))
                        Text(CurrencyFormat.short(hustle.cost)).font(.system(.subheadline, design: .monospaced).weight(.bold)).monospacedDigit()
                    }
                    .frame(minWidth: 88, minHeight: 44)
                    .background(affordable ? amber : Color.white.opacity(0.06))
                    .foregroundColor(affordable ? Color(red: 0.06, green: 0.08, blue: 0.09) : dim)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .disabled(!affordable)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }

    private var footer: some View {
        Button { onClose() } label: {
            Text("CLOSE").font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(cream).frame(maxWidth: .infinity, minHeight: 48)
        }
    }

    private func negotiationBackground(_ index: Int) -> Color {
        guard let negotiationPick else { return Color.white.opacity(0.035) }
        if index == CareerContent.negotiationCorrect { return term.opacity(0.18) }
        if index == negotiationPick { return red.opacity(0.18) }
        return Color.white.opacity(0.035)
    }

    private func negotiate(_ index: Int) {
        guard negotiationPick == nil else { return }
        negotiationPick = index
        if index == CareerContent.negotiationCorrect, !gameState.negotiationDone {
            gameState.monthlyIncome += CareerContent.raiseAmount
            gameState.negotiationDone = true
            PersistenceController.save(gameState)
        }
    }

    private func buy(_ hustle: SideHustle) {
        guard gameState.cash >= hustle.cost, !gameState.sideHustles.contains(hustle.id) else { return }
        gameState.cash -= hustle.cost
        gameState.monthlyIncome += hustle.monthlyBoost
        gameState.sideHustles.append(hustle.id)
        PersistenceController.save(gameState)
    }
}
