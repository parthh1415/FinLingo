//
//  SimulationViews.swift
//  FinLingo
//
//  The running-timeline UI: a slim control bar (age/month, play/pause, speed, live
//  net-worth sparkline) and the life-event decision modal.
//

import SwiftUI

// Shared terminal palette (matches the rest of the game).
private let simScreen = Color(red: 0.055, green: 0.075, blue: 0.09)
private let simEdge = Color(red: 0.83, green: 0.66, blue: 0.33)
private let simCream = Color(red: 0.96, green: 0.90, blue: 0.70)
private let simAmber = Color(red: 0.93, green: 0.70, blue: 0.32)
private let simTerm = Color(red: 0.55, green: 0.80, blue: 0.52)
private let simRed = Color(red: 0.86, green: 0.28, blue: 0.24)
private var simDim: Color { simCream.opacity(0.5) }

/// A tiny net-worth line from the running history.
struct NetWorthSparkline: View {
    let values: [Double]
    var color: Color = simTerm

    var body: some View {
        GeometryReader { geo in
            let pts = values.count >= 2 ? values : [values.first ?? 0, values.first ?? 0]
            let lo = pts.min() ?? 0
            let hi = pts.max() ?? 1
            let span = max(hi - lo, 0.0001)
            Path { p in
                for (i, v) in pts.enumerated() {
                    let x = geo.size.width * CGFloat(i) / CGFloat(pts.count - 1)
                    let y = geo.size.height * (1 - CGFloat((v - lo) / span))
                    i == 0 ? p.move(to: CGPoint(x: x, y: y)) : p.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
        }
    }
}

/// The always-on control bar for the life simulation.
struct SimBar: View {
    @ObservedObject var sim: SimulationEngine
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack(spacing: 10) {
            Button { sim.togglePause() } label: {
                Image(systemName: sim.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
                    .frame(width: 30, height: 26)
                    .background(simAmber)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            Button { sim.cycleSpeed() } label: {
                Text("\(sim.speed)×")
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundColor(simCream)
                    .frame(width: 30, height: 26)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("Age \(Int(sim.age)) · Month \(gameState.monthIndex)")
                    .font(.system(.caption2, design: .monospaced)).foregroundColor(simDim)
                NetWorthSparkline(values: gameState.netWorthHistory)
                    .frame(height: 14)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(simScreen.opacity(0.92))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(simEdge.opacity(0.5), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .font(.system(.body, design: .monospaced))
    }
}

/// A life-event decision card. Choosing shows the outcome, then Continue resolves it.
struct LifeEventView: View {
    let event: LifeEvent
    var onResolve: (LifeEvent.Choice) -> Void

    @State private var picked: LifeEvent.Choice?

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 14) {
                Text(event.emoji).font(.system(size: 44))
                Text(event.title).font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(simCream)
                    .multilineTextAlignment(.center)

                if let picked {
                    Text(picked.outcome)
                        .font(.system(.subheadline, design: .monospaced)).foregroundColor(simCream.opacity(0.85))
                        .multilineTextAlignment(.center).lineSpacing(3)
                    effectRow(picked)
                    Button { onResolve(picked) } label: {
                        Text("CONTINUE").font(.system(.subheadline, design: .monospaced).weight(.bold))
                            .foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
                            .frame(maxWidth: .infinity, minHeight: 46).background(simAmber)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }.buttonStyle(.clicky)
                } else {
                    Text(event.detail)
                        .font(.system(.subheadline, design: .monospaced)).foregroundColor(simCream.opacity(0.85))
                        .multilineTextAlignment(.center).lineSpacing(3)
                    ForEach(event.choices) { choice in
                        Button { picked = choice } label: {
                            Text(choice.label).font(.system(.subheadline, design: .monospaced).weight(.semibold))
                                .foregroundColor(simCream)
                                .frame(maxWidth: .infinity, minHeight: 46)
                                .background(Color.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(simEdge.opacity(0.4), lineWidth: 1))
                        }.buttonStyle(.clicky)
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: 340)
            .background(simScreen)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(simEdge.opacity(0.75), lineWidth: 2))
            .padding(.horizontal, 24)
        }
        .font(.system(.body, design: .monospaced))
    }

    private func effectRow(_ c: LifeEvent.Choice) -> some View {
        HStack(spacing: 10) {
            if c.cash != 0 { tag("Cash", c.cash) }
            if c.invested != 0 { tag("Invest", c.invested) }
            if c.debt != 0 { tag("Debt", c.debt, invert: true) }
            if c.income != 0 { tag("Income", c.income, suffix: "/mo") }
        }
    }

    private func tag(_ label: String, _ v: Double, invert: Bool = false, suffix: String = "") -> some View {
        // For most metrics up is good (green); for debt, up is bad (red).
        let good = invert ? v < 0 : v > 0
        return Text("\(v > 0 ? "+" : "")\(CurrencyFormat.short(abs(v)))\(suffix) \(label)")
            .font(.system(size: 10, design: .monospaced).weight(.bold))
            .foregroundColor(good ? simTerm : simRed)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background((good ? simTerm : simRed).opacity(0.15))
            .clipShape(Capsule())
    }
}
