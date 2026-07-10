//
//  FutureYou.swift
//  FinLingo
//
//  The payoff screen. It takes what the player already set — income, budget invest split,
//  side hustles, current net worth — and projects their wealth out to retirement, with an
//  animated curve, milestone flags, and a faded "if you invested more" line to show the lever.
//  No new inputs beyond age; it just makes everything they've done feel like it matters.
//

import SwiftUI

struct FutureYouView: View {
    @ObservedObject var gameState: GameState
    var onBack: () -> Void

    @State private var age: Double
    @State private var reveal = 0.0

    init(gameState: GameState, onBack: @escaping () -> Void) {
        self.gameState = gameState
        self.onBack = onBack
        _age = State(initialValue: Double(min(max(gameState.age, 16), 64)))
    }

    private let targetAge = 65
    private let thresholds: [(label: String, value: Double)] = [
        ("$100k", 100_000), ("$500k", 500_000), ("$1M", 1_000_000)
    ]

    private let screen = Color(red: 0.055, green: 0.075, blue: 0.09)
    private let edge = Color(red: 0.83, green: 0.66, blue: 0.33)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let green = Color(red: 0.55, green: 0.80, blue: 0.52)
    private var dim: Color { cream.opacity(0.5) }

    private var allocation: Double { min(max(gameState.investAllocation, 0), 1) }
    private var monthly: Double { gameState.monthlyIncome * allocation }
    private var boostedRate: Double { max(allocation, min(allocation + 0.2, 0.9)) }
    private var boostedMonthly: Double { gameState.monthlyIncome * boostedRate }

    // Year-by-year net worth from the player's current age to retirement.
    private func project(monthly: Double) -> [Double] {
        let start = Int(age)
        guard targetAge > start else { return [max(gameState.netWorth, 0)] }
        var balance = max(gameState.netWorth, 0)
        var series = [balance]
        let r = FinRates.annualReturn / 12
        for _ in start..<targetAge {
            for _ in 0..<12 { balance += balance * r + monthly }
            series.append(balance)
        }
        return series
    }

    private var current: [Double] { project(monthly: monthly) }
    private var boosted: [Double] { project(monthly: boostedMonthly) }

    private func milestoneAge(_ value: Double, in series: [Double]) -> Int? {
        for (i, v) in series.enumerated() where v >= value { return Int(age) + i }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Button { onBack() } label: {
                    Text("‹ TOOLS").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(dim)
                }
                headline
                chart.frame(height: 170)
                legend
                CalcSliderLite(label: "Your age now", value: $age, range: 16...64, step: 1, display: "\(Int(age))")
                milestones
                nudge
            }
            .padding(16)
        }
        .frame(maxHeight: 520)
        .onAppear {
            reveal = 0
            withAnimation(.easeOut(duration: 1.3)) { reveal = 1 }
        }
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(gameState.playerName.isEmpty ? "AT \(targetAge), YOU'RE ON TRACK FOR" : "\(gameState.playerName.uppercased()) — AT \(targetAge) YOU'RE ON TRACK FOR")
                .font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(green)
            Text(CurrencyFormat.short(current.last ?? 0))
                .font(.system(size: 40, weight: .heavy, design: .monospaced)).foregroundColor(cream).monospacedDigit()
            Text("from \(CurrencyFormat.signed(gameState.netWorth)) today, investing \(Int(allocation * 100))% of a \(CurrencyFormat.short(gameState.monthlyIncome))/mo income")
                .font(.system(.caption2, design: .monospaced)).foregroundColor(dim)
        }
    }

    private var chart: some View {
        GeometryReader { geo in
            let cur = current
            let boo = boosted
            let hi = max(cur.max() ?? 1, boo.max() ?? 1, 1)
            let w = geo.size.width
            let h = geo.size.height

            // Soft gradient fill under your path.
            Path { p in
                p.move(to: CGPoint(x: 0, y: h))
                for (i, v) in cur.enumerated() {
                    let x = cur.count <= 1 ? 0 : w * CGFloat(i) / CGFloat(cur.count - 1)
                    let y = h * (1 - CGFloat(min(v, hi) / hi))
                    p.addLine(to: CGPoint(x: x, y: y))
                }
                p.addLine(to: CGPoint(x: w, y: h))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [green.opacity(0.28), green.opacity(0.02)], startPoint: .top, endPoint: .bottom))
            .opacity(reveal)

            // Faded "if you invested more" line.
            line(boo, w: w, h: h, hi: hi).trim(from: 0, to: reveal)
                .stroke(amber.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
            // The player's actual trajectory.
            line(cur, w: w, h: h, hi: hi).trim(from: 0, to: reveal)
                .stroke(green, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

            // Milestone flags on the current path.
            ForEach(thresholds.indices, id: \.self) { idx in
                if let mAge = milestoneAge(thresholds[idx].value, in: cur) {
                    let i = mAge - Int(age)
                    let x = cur.count <= 1 ? 0 : w * CGFloat(i) / CGFloat(cur.count - 1)
                    let y = h * (1 - CGFloat(min(cur[i], hi) / hi))
                    ZStack {
                        Circle().fill(amber).frame(width: 7, height: 7)
                        Text("\(thresholds[idx].label)·\(mAge)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(amber)
                            .fixedSize()
                            .offset(y: -12)
                    }
                    .position(x: x, y: max(y, 10))
                    .opacity(reveal)
                }
            }
        }
    }

    private func line(_ series: [Double], w: CGFloat, h: CGFloat, hi: Double) -> Path {
        Path { p in
            for (i, v) in series.enumerated() {
                let x = series.count <= 1 ? 0 : w * CGFloat(i) / CGFloat(series.count - 1)
                let y = h * (1 - CGFloat(min(v, hi) / hi))
                if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
            }
        }
    }

    private var legend: some View {
        HStack(spacing: 16) {
            legendDot(green, "your path")
            legendDot(amber, "if you invested \(Int(boostedRate * 100))%")
            Spacer()
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).font(.system(size: 10, design: .monospaced)).foregroundColor(dim)
        }
    }

    private var milestones: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(thresholds.indices, id: \.self) { idx in
                let t = thresholds[idx]
                HStack {
                    Text(t.label).font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(cream)
                    Spacer()
                    if let mAge = milestoneAge(t.value, in: current) {
                        Text("at age \(mAge)").font(.system(.caption, design: .monospaced)).foregroundColor(green)
                    } else {
                        Text("keep going").font(.system(.caption, design: .monospaced)).foregroundColor(dim)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var nudge: some View {
        Text(allocation <= 0
             ? "You're not investing yet. Open Budget and pick a plan — watch this line lift off."
             : "The dashed line is you investing \(Int(boostedRate * 100))%. A little more each month, a very different age-65.")
            .font(.system(.caption, design: .monospaced)).foregroundColor(dim).lineSpacing(2)
    }
}

// A self-contained slider so FutureYou doesn't depend on the calculator components.
private struct CalcSliderLite: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let display: String

    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.system(.caption, design: .monospaced)).foregroundColor(cream)
                Spacer()
                Text(display).font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(amber)
            }
            Slider(value: $value, in: range, step: step).tint(amber)
        }
    }
}
