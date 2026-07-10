//
//  SimulatorView.swift
//  FinLingo
//
//  The right laptop: a hands-on trading sandbox. Real historical daily prices play out one
//  day at a time; the player buys and sells with practice money and watches their P&L. Cash
//  out in profit and the gains convert to in-game cash (once per scenario). This is practice,
//  not a quiz — Lessons teaches the theory, the Simulator is where you actually do it.
//

import SwiftUI

struct TradeScenario: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let blurb: String
    let prices: [Double] // real daily closes, oldest first
}

enum TradingContent {
    static let startingCash: Double = 10_000

    // Real AAPL daily closes (source: market data), two non-overlapping windows.
    static let scenarios: [TradeScenario] = [
        TradeScenario(
            id: "aapl_summer",
            title: "Buy the dip?",
            symbol: "AAPL",
            blurb: "A month of Apple. It slides, then rips. Can you time it?",
            prices: [308.33, 310.85, 312.51, 312.06, 306.31, 315.20, 310.26, 311.23, 307.34,
                     301.54, 290.55, 291.58, 295.63, 291.13, 296.42, 299.24, 295.95, 298.01,
                     297.01, 294.30, 293.08, 275.15, 283.78, 281.74, 289.36, 294.38, 308.63,
                     312.66, 310.66, 313.39, 316.22]
        ),
        TradeScenario(
            id: "aapl_spring",
            title: "Riding a trend",
            symbol: "AAPL",
            blurb: "An earlier stretch — a steadier climb with a few wobbles.",
            prices: [246.63, 253.79, 255.63, 255.92, 258.86, 253.50, 258.90, 260.49, 260.48,
                     259.20, 258.83, 266.43, 263.40, 270.23, 273.05, 266.17, 273.17, 273.43,
                     271.06, 267.61, 270.71, 270.17, 271.35, 280.14, 276.83, 284.18, 287.51,
                     287.44, 293.32]
        ),
    ]
}

struct SimulatorView: View {
    @ObservedObject var gameState: GameState
    var onClose: () -> Void

    @State private var selected: TradeScenario?

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
                if let scenario = selected {
                    TradingSandbox(scenario: scenario, gameState: gameState) { selected = nil }
                } else {
                    scenarioList
                }
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
                Circle().fill(Color(red: 0.86, green: 0.28, blue: 0.24)).frame(width: 9, height: 9)
                Circle().fill(amber).frame(width: 9, height: 9)
                Circle().fill(term).frame(width: 9, height: 9)
            }
            Text("simulator.finlingo").font(.system(.footnote, design: .monospaced)).foregroundColor(dim)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
    }

    private var scenarioList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Text("> practice trading real market history").font(.system(.caption, design: .monospaced))
                    .foregroundColor(term.opacity(0.9)).frame(maxWidth: .infinity, alignment: .leading)
                ForEach(TradingContent.scenarios) { scenario in
                    Button { selected = scenario } label: { scenarioRow(scenario) }.buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .frame(maxHeight: 440)
    }

    private func scenarioRow(_ scenario: TradeScenario) -> some View {
        let done = gameState.completedChallenges.contains("trade_\(scenario.id)")
        return VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("\(scenario.symbol) · \(scenario.title)").font(.system(.headline, design: .monospaced)).foregroundColor(cream)
                Spacer()
                if done { Text("TRADED ✓").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(term) }
            }
            Text(scenario.blurb).font(.system(.caption, design: .monospaced)).foregroundColor(dim)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
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
}

private struct TradingSandbox: View {
    let scenario: TradeScenario
    @ObservedObject var gameState: GameState
    var onBack: () -> Void

    @State private var day = 0
    @State private var cash = TradingContent.startingCash
    @State private var shares = 0.0
    @State private var cashedOut = false
    @State private var rewardGiven = 0.0

    private let screenGreen = Color(red: 0.55, green: 0.80, blue: 0.52)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let red = Color(red: 0.86, green: 0.28, blue: 0.24)
    private var dim: Color { cream.opacity(0.45) }

    private var price: Double { scenario.prices[day] }
    private var isLastDay: Bool { day >= scenario.prices.count - 1 }
    private var portfolio: Double { cash + shares * price }
    private var profit: Double { portfolio - TradingContent.startingCash }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                chart
                positionPanel
                if cashedOut { resultPanel } else { controls }
                Button { onBack() } label: {
                    Text("‹ BACK").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(dim)
                }
            }
            .padding(16)
        }
        .frame(maxHeight: 500)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(scenario.symbol).font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(cream)
                Text("Day \(day + 1)/\(scenario.prices.count)").font(.system(.caption2, design: .monospaced)).foregroundColor(dim)
            }
            Spacer()
            Text("$" + String(format: "%.2f", price)).font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(amber).monospacedDigit()
        }
    }

    private var chart: some View {
        GeometryReader { geo in
            let visible = Array(scenario.prices[0...day])
            let lo = visible.min() ?? 0
            let hi = visible.max() ?? 1
            let span = max(hi - lo, 0.0001)
            Path { p in
                for (i, value) in visible.enumerated() {
                    let x = visible.count == 1 ? 0 : geo.size.width * CGFloat(i) / CGFloat(scenario.prices.count - 1)
                    let y = geo.size.height * (1 - CGFloat((value - lo) / span))
                    if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(profit >= 0 ? screenGreen : red, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
        }
        .frame(height: 90)
        .padding(10)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var positionPanel: some View {
        HStack {
            stat("CASH", "$" + String(format: "%.0f", cash), cream)
            Spacer()
            stat("SHARES", String(format: "%.2f", shares), cream)
            Spacer()
            stat("VALUE", "$" + String(format: "%.0f", portfolio), profit >= 0 ? screenGreen : red)
        }
    }

    private func stat(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 10, design: .monospaced)).foregroundColor(dim)
            Text(value).font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundColor(color).monospacedDigit()
        }
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                actionButton("BUY 25%", enabled: cash > price, color: screenGreen) { buy() }
                actionButton("SELL ALL", enabled: shares > 0, color: red) { sellAll() }
            }
            actionButton(isLastDay ? "CASH OUT" : "NEXT DAY ▸", enabled: true, color: amber) {
                if isLastDay { cashOut() } else { day += 1 }
            }
        }
    }

    private func actionButton(_ label: String, enabled: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(enabled ? Color(red: 0.06, green: 0.08, blue: 0.09) : dim)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(enabled ? color : Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .disabled(!enabled)
    }

    private var resultPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(profit >= 0 ? "YOU FINISHED UP" : "YOU FINISHED DOWN")
                .font(.system(.caption2, design: .monospaced).weight(.bold))
                .foregroundColor(profit >= 0 ? screenGreen : red)
            Text("\(profit >= 0 ? "+" : "")$" + String(format: "%.0f", profit) + " on your $" + String(format: "%.0f", TradingContent.startingCash) + " practice fund")
                .font(.system(.subheadline, design: .monospaced)).foregroundColor(cream)
            if rewardGiven > 0 {
                Text("Cashed \(CurrencyFormat.short(rewardGiven)) of profit into your wallet.")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(amber)
            } else {
                Text("No profit to bank this time — the practice is free. Try again?")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(dim)
            }
            actionButton("TRADE AGAIN", enabled: true, color: amber) { reset() }
        }
        .padding(12)
        .background(screenGreen.opacity(profit >= 0 ? 0.10 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func buy() {
        let spend = cash * 0.25
        guard spend >= price * 0.0001 else { return }
        shares += spend / price
        cash -= spend
    }

    private func sellAll() {
        cash += shares * price
        shares = 0
    }

    private func cashOut() {
        sellAll()
        cashedOut = true
        // Bank the profit once per scenario — practice paying off in real cash.
        let key = "trade_\(scenario.id)"
        if profit > 0, !gameState.completedChallenges.contains(key) {
            gameState.cash += profit
            gameState.completedChallenges.insert(key)
            rewardGiven = profit
            PersistenceController.save(gameState)
        }
    }

    private func reset() {
        day = 0; cash = TradingContent.startingCash; shares = 0; cashedOut = false; rewardGiven = 0
    }
}
