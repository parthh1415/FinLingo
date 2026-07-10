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
        TradeScenario(
            id: "nvda_run",
            title: "The AI rocket",
            symbol: "NVDA",
            blurb: "Nvidia on a tear — huge upside, gut-check volatility.",
            prices: [165.17, 174.40, 175.75, 177.39, 177.64, 178.10, 182.08, 183.91, 188.63,
                     189.31, 196.51, 198.87, 198.35, 201.68, 202.06, 199.88, 202.50, 199.64,
                     208.27, 216.61, 213.17, 209.25, 199.57, 198.45, 198.48, 196.50, 207.83,
                     211.50, 215.20]
        ),
    ]
}

private enum SimTool { case futureYou, trading, retirement, debt, emergency, grower }

struct SimulatorView: View {
    @ObservedObject var gameState: GameState
    var onClose: () -> Void

    @State private var tool: SimTool?
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
                switch tool {
                case .none:
                    toolHub
                case .futureYou:
                    FutureYouView(gameState: gameState) { tool = nil }
                case .trading:
                    if let scenario = selected {
                        TradingSandbox(scenario: scenario, gameState: gameState) { selected = nil }
                    } else {
                        scenarioList
                    }
                case .retirement:
                    RetirementCalculator(gameState: gameState) { tool = nil }
                case .grower:
                    CompoundGrower { tool = nil }
                case .debt:
                    DebtPayoffCalculator { tool = nil }
                case .emergency:
                    EmergencyFundCalculator(gameState: gameState) { tool = nil }
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

    // The hub: pick a hands-on tool. Each pairs with a lesson topic.
    private var toolHub: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Text("> hands-on tools — practice what the Lessons teach")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(term.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                featuredCard("🔮 Future You", "See where your money moves take you by 65.") { tool = .futureYou }
                toolCard("Trading sandbox", "Buy & sell real market history. Pairs with: investing.") { tool = .trading }
                toolCard("401(k) calculator", "See your nest egg grow. Pairs with: compound interest.") { tool = .retirement }
                toolCard("Invest $X/month", "Watch small monthly amounts snowball. Pairs with: saving.") { tool = .grower }
                toolCard("Debt payoff", "Crush a balance faster. Pairs with: using credit.") { tool = .debt }
                toolCard("Emergency fund", "How many months are you covered? Pairs with: safety net.") { tool = .emergency }
            }
            .padding(16)
        }
        .frame(maxHeight: 440)
    }

    // A highlighted card for the headline "Future You" projection.
    private func featuredCard(_ title: String, _ blurb: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.system(.headline, design: .monospaced).weight(.bold)).foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
                    Text(blurb).font(.system(.caption, design: .monospaced)).foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09).opacity(0.7))
                }
                Spacer()
                Text("›").font(.system(.title2, design: .monospaced).weight(.bold)).foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(amber)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func toolCard(_ title: String, _ blurb: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(.headline, design: .monospaced)).foregroundColor(cream)
                Text(blurb).font(.system(.caption, design: .monospaced)).foregroundColor(dim)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.035))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.06), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var scenarioList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Button { tool = nil } label: {
                    Text("‹ TOOLS").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(dim)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
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

// The hands-on companion to the compound-interest lesson: project a 401(k) and see how
// much of the final number is the employer match and pure growth rather than your own money.
private struct RetirementCalculator: View {
    @ObservedObject var gameState: GameState
    var onBack: () -> Void

    @State private var contribPct = 0.06   // your contribution, fraction of salary
    @State private var years = 30.0

    private let employerMatchCap = 0.03     // employer matches dollar-for-dollar up to 3%
    private let annualReturn = FinRates.annualReturn

    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)
    private var dim: Color { cream.opacity(0.45) }

    private var salary: Double { gameState.monthlyIncome > 0 ? gameState.monthlyIncome * 12 : 60_000 }
    private var employerPct: Double { min(contribPct, employerMatchCap) }

    private var projection: (balance: Double, you: Double, employer: Double, growth: Double) {
        let r = annualReturn / 12
        let n = years * 12
        let annual = salary * (contribPct + employerPct)
        let pmt = annual / 12
        let balance = r == 0 ? pmt * n : pmt * ((pow(1 + r, n) - 1) / r)
        let you = salary * contribPct * years
        let employer = salary * employerPct * years
        return (balance, you, employer, max(0, balance - you - employer))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Button { onBack() } label: {
                    Text("‹ TOOLS").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(dim)
                }
                Text("401(k) projection").font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(cream)
                Text("Salary $\(Int(salary))/yr · \(Int(annualReturn * 100))% return · employer matches to \(Int(employerMatchCap * 100))%")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(dim)

                slider(label: "You contribute", value: $contribPct, range: 0...0.15, step: 0.01, display: "\(Int(contribPct * 100))% of salary")
                slider(label: "Years invested", value: $years, range: 5...40, step: 1, display: "\(Int(years)) years")

                VStack(alignment: .leading, spacing: 6) {
                    Text("PROJECTED AT RETIREMENT").font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(term)
                    Text(CurrencyFormat.short(projection.balance))
                        .font(.system(size: 34, weight: .heavy, design: .monospaced)).foregroundColor(amber).monospacedDigit()
                }

                breakdown("You put in", projection.you, cream)
                breakdown("Employer match (free money)", projection.employer, term)
                breakdown("Investment growth", projection.growth, term)

                Text(employerPct < employerMatchCap
                     ? "You're leaving free money on the table — contribute at least \(Int(employerMatchCap * 100))% to grab the full match."
                     : "Nice — you're capturing the full employer match, then compounding does the heavy lifting.")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(dim).lineSpacing(2)
            }
            .padding(16)
        }
        .frame(maxHeight: 500)
    }

    private func slider(label: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, display: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.system(.caption, design: .monospaced)).foregroundColor(cream)
                Spacer()
                Text(display).font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(amber)
            }
            Slider(value: value, in: range, step: step).tint(amber)
        }
    }

    private func breakdown(_ label: String, _ amount: Double, _ color: Color) -> some View {
        HStack {
            Text(label).font(.system(.caption, design: .monospaced)).foregroundColor(dim)
            Spacer()
            Text(CurrencyFormat.short(amount)).font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundColor(color).monospacedDigit()
        }
    }
}

// MARK: - Shared calculator building blocks

private let calcGreen = Color(red: 0.55, green: 0.80, blue: 0.52)
private let calcCream = Color(red: 0.96, green: 0.90, blue: 0.70)
private let calcAmber = Color(red: 0.93, green: 0.70, blue: 0.32)
private let calcRed = Color(red: 0.86, green: 0.28, blue: 0.24)
private let calcDim = Color(red: 0.96, green: 0.90, blue: 0.70).opacity(0.45)

private struct CalcScreen<Content: View>: View {
    let title: String
    let subtitle: String
    var onBack: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Button { onBack() } label: {
                    Text("‹ TOOLS").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(calcDim)
                }
                Text(title).font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(calcCream)
                Text(subtitle).font(.system(.caption, design: .monospaced)).foregroundColor(calcDim).lineSpacing(2)
                content
            }
            .padding(16)
        }
        .frame(maxHeight: 500)
    }
}

private struct CalcSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let display: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.system(.caption, design: .monospaced)).foregroundColor(calcCream)
                Spacer()
                Text(display).font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(calcAmber)
            }
            Slider(value: $value, in: range, step: step).tint(calcAmber)
        }
    }
}

private struct CalcHeadline: View {
    let label: String
    let value: String
    var color: Color = calcAmber
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(calcGreen)
            Text(value).font(.system(size: 34, weight: .heavy, design: .monospaced)).foregroundColor(color).monospacedDigit()
        }
    }
}

private struct CalcRow: View {
    let label: String
    let value: String
    var color: Color = calcCream
    var body: some View {
        HStack {
            Text(label).font(.system(.caption, design: .monospaced)).foregroundColor(calcDim)
            Spacer()
            Text(value).font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundColor(color).monospacedDigit()
        }
    }
}

private struct CalcNote: View {
    let text: String
    var body: some View {
        Text(text).font(.system(.caption, design: .monospaced)).foregroundColor(calcDim).lineSpacing(2)
    }
}

// MARK: - Invest $X/month (pairs with the saving / compounding lessons)

private struct CompoundGrower: View {
    var onBack: () -> Void
    @State private var monthly = 200.0
    @State private var years = 20.0
    @State private var rate = FinRates.annualReturn

    private var future: Double {
        let r = rate / 12, n = years * 12
        return r == 0 ? monthly * n : monthly * ((pow(1 + r, n) - 1) / r)
    }
    private var contributed: Double { monthly * 12 * years }

    var body: some View {
        CalcScreen(title: "Invest $X a month", subtitle: "Small, steady amounts turn into a lot given time.", onBack: onBack) {
            CalcSlider(label: "Monthly amount", value: $monthly, range: 25...1000, step: 25, display: "$\(Int(monthly))/mo")
            CalcSlider(label: "Years", value: $years, range: 1...40, step: 1, display: "\(Int(years)) yr")
            CalcSlider(label: "Annual return", value: $rate, range: 0.02...0.10, step: 0.01, display: "\(Int(rate * 100))%")
            CalcHeadline(label: "IN \(Int(years)) YEARS YOU'D HAVE", value: CurrencyFormat.short(future))
            CalcRow(label: "You contributed", value: CurrencyFormat.short(contributed))
            CalcRow(label: "Investment growth", value: CurrencyFormat.short(max(0, future - contributed)), color: calcGreen)
            CalcNote(text: "The growth line usually dwarfs what you put in — that's compounding, and it rewards starting early.")
        }
    }
}

// MARK: - Debt payoff (pairs with the credit lesson)

private struct DebtPayoffCalculator: View {
    var onBack: () -> Void
    @State private var balance = 3000.0
    @State private var apr = 0.22
    @State private var payment = 150.0

    // Months to clear the balance and the interest paid along the way.
    private var result: (months: Int?, interest: Double) {
        let i = apr / 12
        // Zero-interest debt is just balance ÷ payment.
        if i == 0 {
            return (Int(ceil(balance / payment)), 0)
        }
        // Payment must clear more than the monthly interest or the balance never shrinks.
        guard payment > balance * i else { return (nil, 0) }
        // Amortize month by month so the interest total is exact — the final payment is partial,
        // so a flat payment × months would over-count it.
        var remaining = balance
        var interest = 0.0
        var months = 0
        while remaining > 0.005 && months < 1200 {
            let monthInterest = remaining * i
            interest += monthInterest
            remaining += monthInterest - payment
            months += 1
        }
        return (months, max(0, interest))
    }

    var body: some View {
        CalcScreen(title: "Debt payoff", subtitle: "See how fast a card clears — and what the interest costs you.", onBack: onBack) {
            CalcSlider(label: "Balance", value: $balance, range: 500...15000, step: 100, display: "$\(Int(balance))")
            CalcSlider(label: "Interest rate (APR)", value: $apr, range: 0...0.30, step: 0.01, display: "\(Int(apr * 100))%")
            CalcSlider(label: "Monthly payment", value: $payment, range: 25...1000, step: 25, display: "$\(Int(payment))/mo")
            if let months = result.months {
                CalcHeadline(label: "PAID OFF IN", value: months >= 12 ? "\(months / 12)y \(months % 12)m" : "\(months) mo")
                CalcRow(label: "Total interest paid", value: CurrencyFormat.short(result.interest), color: calcRed)
                CalcNote(text: "Nudge the payment up and watch both the time and the interest drop — that's why paying more than the minimum matters.")
            } else {
                CalcHeadline(label: "PAID OFF IN", value: "never", color: calcRed)
                CalcNote(text: "Your payment barely covers the interest, so the balance never shrinks. Raise the monthly payment above the interest to make progress.")
            }
        }
    }
}

// MARK: - Emergency fund (pairs with the safety-net lesson)

private struct EmergencyFundCalculator: View {
    @ObservedObject var gameState: GameState
    var onBack: () -> Void

    @State private var essentials: Double
    @State private var savings = 2000.0

    init(gameState: GameState, onBack: @escaping () -> Void) {
        self.gameState = gameState
        self.onBack = onBack
        let seed = gameState.monthlySpending > 0 ? gameState.monthlySpending : 2000
        _essentials = State(initialValue: min(max(seed, 500), 6000)) // keep inside the slider range
    }

    private var monthsCovered: Double { essentials > 0 ? savings / essentials : 0 }
    private var gapToThree: Double { max(0, essentials * 3 - savings) }

    var body: some View {
        CalcScreen(title: "Emergency fund", subtitle: "A cushion of essential expenses keeps one bad month from becoming debt.", onBack: onBack) {
            CalcSlider(label: "Monthly essentials", value: $essentials, range: 500...6000, step: 100, display: "$\(Int(essentials))/mo")
            CalcSlider(label: "Saved so far", value: $savings, range: 0...30000, step: 250, display: "$\(Int(savings))")
            CalcHeadline(label: "YOU'RE COVERED FOR",
                         value: String(format: "%.1f months", monthsCovered),
                         color: monthsCovered >= 3 ? calcGreen : calcAmber)
            CalcRow(label: "3-month target", value: CurrencyFormat.short(essentials * 3))
            CalcRow(label: "6-month target", value: CurrencyFormat.short(essentials * 6))
            CalcNote(text: gapToThree > 0
                     ? "You're \(CurrencyFormat.short(gapToThree)) away from a 3-month cushion — a solid first goal before investing heavily."
                     : "You've got at least 3 months covered. Nice cushion — now money can go to work investing.")
        }
    }
}
