//
//  BudgetView.swift
//  FinLingo
//
//  Opened from the EARNING chip. The player picks how to split their income across
//  needs/wants/save/invest. The invested slice compounds into net worth over time, so the
//  budget choice visibly changes how fast wealth grows.
//

import SwiftUI

struct BudgetStrategy: Identifiable {
    let id: String
    let name: String
    let blurb: String
    let needs: Int
    let wants: Int
    let save: Int
    let invest: Int
    var investAllocation: Double { Double(invest) / 100 }
}

enum BudgetContent {
    static let strategies: [BudgetStrategy] = [
        BudgetStrategy(id: "survive", name: "Paycheck to paycheck", blurb: "Everything goes to living. Nothing compounds.", needs: 65, wants: 35, save: 0, invest: 0),
        BudgetStrategy(id: "503020", name: "The 50/30/20", blurb: "A balanced split — 20% toward saving and investing.", needs: 50, wants: 30, save: 10, invest: 10),
        BudgetStrategy(id: "builder", name: "Wealth builder", blurb: "Lean living, 30% invested. Net worth climbs fastest.", needs: 45, wants: 15, save: 10, invest: 30),
    ]
}

struct BudgetView: View {
    @ObservedObject var gameState: GameState
    var onClose: () -> Void

    @State private var showShare = false

    private let screen = Color(red: 0.055, green: 0.075, blue: 0.09)
    private let edge = Color(red: 0.83, green: 0.66, blue: 0.33)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)
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

            if showShare {
                ShareProgressView(gameState: gameState) { showShare = false }
            }
        }
        .font(.system(.body, design: .monospaced))
    }

    private var titleBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 5) {
                Circle().fill(Color(red: 0.86, green: 0.28, blue: 0.24)).frame(width: 9, height: 9)
                Circle().fill(amber).frame(width: 9, height: 9)
                Circle().fill(term).frame(width: 9, height: 9)
            }
            Text("budget.finlingo").font(.system(.footnote, design: .monospaced)).foregroundColor(dim)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    stat("NET WORTH", CurrencyFormat.signed(gameState.netWorth), cream)
                    Spacer()
                    stat("INVESTED", CurrencyFormat.short(gameState.investedBalance), term)
                }

                Button { showShare = true } label: {
                    Label("Share my progress", systemImage: "square.and.arrow.up")
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(term)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.clicky)

                peerBanner

                Text("Your invested share grows ~7%/yr. Pick a plan:")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(dim)

                ForEach(BudgetContent.strategies) { strategy in
                    Button { choose(strategy) } label: { strategyCard(strategy) }
                        .buttonStyle(.clicky)
                }
            }
            .padding(16)
        }
        .frame(maxHeight: 460)
    }

    private func stat(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(.caption2, design: .monospaced)).foregroundColor(dim)
            Text(value).font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(color).monospacedDigit()
        }
    }

    // Anonymized "you're not alone" social proof for the player's income band.
    private var peerBanner: some View {
        let s = PeerInsights.split(forIncome: gameState.monthlyIncome)
        return VStack(alignment: .leading, spacing: 6) {
            Text("🌐 Peers earning \(s.band) chose:")
                .font(.system(.caption, design: .monospaced)).foregroundColor(term)
            HStack(spacing: 6) {
                peerPct("Paycheck", s.survive, id: "survive")
                peerPct("50/30/20", s.balanced, id: "503020")
                peerPct("Builder", s.builder, id: "builder")
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func peerPct(_ label: String, _ pct: Int, id: String) -> some View {
        let top = PeerInsights.mostPopularId(forIncome: gameState.monthlyIncome) == id
        return VStack(spacing: 2) {
            Text("\(pct)%").font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundColor(top ? amber : cream)
            Text(label).font(.system(size: 9, design: .monospaced)).foregroundColor(dim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(top ? amber.opacity(0.12) : Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func strategyCard(_ strategy: BudgetStrategy) -> some View {
        let selected = abs(gameState.investAllocation - strategy.investAllocation) < 0.001
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(strategy.name).font(.system(.headline, design: .monospaced)).foregroundColor(cream)
                Spacer()
                if selected { Text("ACTIVE").font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(term) }
            }
            Text(strategy.blurb).font(.system(.caption, design: .monospaced)).foregroundColor(dim)
            HStack(spacing: 6) {
                split("Needs", strategy.needs)
                split("Wants", strategy.wants)
                split("Save", strategy.save)
                split("Invest", strategy.invest)
            }
            peerProof(for: strategy)
        }
        .padding(12)
        .background(selected ? amber.opacity(0.14) : Color.white.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(selected ? amber.opacity(0.6) : Color.white.opacity(0.06), lineWidth: 1))
    }

    private func peerProof(for strategy: BudgetStrategy) -> some View {
        let pct = PeerInsights.pct(forIncome: gameState.monthlyIncome, strategyId: strategy.id)
        let top = PeerInsights.mostPopularId(forIncome: gameState.monthlyIncome) == strategy.id
        return Text("\(pct)% of peers like you chose this\(top ? "  ★ most popular" : "")")
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(top ? amber : dim)
    }

    private func split(_ label: String, _ pct: Int) -> some View {
        VStack(spacing: 1) {
            Text("\(pct)%").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(label == "Invest" ? term : cream)
            Text(label).font(.system(size: 9, design: .monospaced)).foregroundColor(dim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var footer: some View {
        Button { onClose() } label: {
            Text("CLOSE").font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(cream).frame(maxWidth: .infinity, minHeight: 48)
        }
    }

    private func choose(_ strategy: BudgetStrategy) {
        gameState.investAllocation = strategy.investAllocation
        PersistenceController.save(gameState)
    }
}
