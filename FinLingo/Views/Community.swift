//
//  Community.swift
//  FinLingo
//
//  Backend-free "you're not alone" features: anonymized peer choices (static, income-banded
//  data that reads like real aggregate stats) shown on the Budget board, and a shareable
//  net-worth card the player can post.
//

import SwiftUI

enum PeerInsights {
    struct Split { let survive: Int; let balanced: Int; let builder: Int; let band: String }

    // Illustrative, anonymized distributions of how peers in each income band budget.
    // Percentages are the share choosing paycheck-to-paycheck / 50-30-20 / wealth-builder.
    static func split(forIncome income: Double) -> Split {
        switch income {
        case ..<2500:    return Split(survive: 46, balanced: 40, builder: 14, band: "under $2.5k/mo")
        case 2500..<4500: return Split(survive: 23, balanced: 55, builder: 22, band: "$2.5–4.5k/mo")
        case 4500..<7000: return Split(survive: 14, balanced: 49, builder: 37, band: "$4.5–7k/mo")
        default:          return Split(survive: 9,  balanced: 41, builder: 50, band: "$7k+/mo")
        }
    }

    static func pct(forIncome income: Double, strategyId: String) -> Int {
        let s = split(forIncome: income)
        switch strategyId {
        case "survive": return s.survive
        case "503020": return s.balanced
        case "builder": return s.builder
        default: return 0
        }
    }

    static func mostPopularId(forIncome income: Double) -> String {
        let s = split(forIncome: income)
        let pairs = [("survive", s.survive), ("503020", s.balanced), ("builder", s.builder)]
        return pairs.max { $0.1 < $1.1 }!.0
    }
}

// MARK: - Share card

/// The image a player posts. Fixed proportions so it renders cleanly to a shareable PNG.
struct ShareCard: View {
    @ObservedObject var gameState: GameState

    private let bg = Color(red: 0.055, green: 0.075, blue: 0.09)
    private let edge = Color(red: 0.83, green: 0.66, blue: 0.33)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let green = Color(red: 0.55, green: 0.80, blue: 0.52)
    private var dim: Color { cream.opacity(0.5) }

    // Always at least two points so the curve is a visible line (start vs. now).
    private var points: [Double] {
        let history = gameState.netWorthHistory
        let now = gameState.netWorth
        if history.count >= 2 { return history + [now] }
        return [1000, now]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("FinLingo").font(.system(.headline, design: .monospaced).weight(.bold)).foregroundColor(amber)
                Spacer()
                Text("my money journey").font(.system(.caption, design: .monospaced)).foregroundColor(dim)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("NET WORTH").font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(green)
                Text(CurrencyFormat.short(gameState.netWorth))
                    .font(.system(size: 44, weight: .heavy, design: .monospaced)).foregroundColor(cream).monospacedDigit()
            }

            curve
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .padding(12)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack {
                stat("INCOME", "\(CurrencyFormat.short(gameState.monthlyIncome))/mo", amber)
                Spacer()
                stat("INVESTED", CurrencyFormat.short(gameState.investedBalance), green)
                Spacer()
                stat("LESSONS", "\(gameState.completedLessons.count) done", cream)
            }

            Text("Learning to make my first money moves. Come build with me.")
                .font(.system(.caption, design: .monospaced)).foregroundColor(dim).lineSpacing(2)
        }
        .padding(20)
        .background(bg)
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(edge.opacity(0.6), lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var curve: some View {
        GeometryReader { geo in
            let pts = points
            let lo = pts.min() ?? 0
            let hi = pts.max() ?? 1
            let span = max(hi - lo, 0.0001)
            let pt: (Int, Double) -> CGPoint = { i, value in
                let x = pts.count <= 1 ? 0 : geo.size.width * CGFloat(i) / CGFloat(pts.count - 1)
                let y = geo.size.height * (1 - CGFloat((value - lo) / span))
                return CGPoint(x: x, y: y)
            }
            let last = pt(pts.count - 1, pts.last ?? 0)

            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: 0, y: geo.size.height))
                    for (i, v) in pts.enumerated() { p.addLine(to: pt(i, v)) }
                    p.addLine(to: CGPoint(x: last.x, y: geo.size.height))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [green.opacity(0.32), green.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                Path { p in
                    for (i, v) in pts.enumerated() { i == 0 ? p.move(to: pt(i, v)) : p.addLine(to: pt(i, v)) }
                }
                .stroke(green, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                Circle().fill(green).frame(width: 8, height: 8).position(last)
            }
        }
    }

    private func stat(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, design: .monospaced)).foregroundColor(dim)
            Text(value).font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(color).monospacedDigit()
        }
    }
}

/// Presents the share card and a system share sheet to post it.
struct ShareProgressView: View {
    @ObservedObject var gameState: GameState
    var onClose: () -> Void

    @State private var shareImage: Image?

    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)

    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea().contentShape(Rectangle()).onTapGesture { onClose() }

            VStack(spacing: 16) {
                if let shareImage {
                    // Show the exact rendered image so the preview always matches what gets posted.
                    shareImage.resizable().scaledToFit().frame(maxWidth: 320, maxHeight: 400)
                    ShareLink(item: shareImage, preview: SharePreview("My FinLingo net worth", image: shareImage)) {
                        Label("Post my progress", systemImage: "square.and.arrow.up")
                            .font(.system(.subheadline, design: .monospaced).weight(.bold))
                            .foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
                            .frame(maxWidth: 320, minHeight: 48)
                            .background(amber)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                } else {
                    ShareCard(gameState: gameState).frame(width: 320, height: 400)
                    ProgressView().tint(amber)
                }

                Button { onClose() } label: {
                    Text("Close").font(.system(.subheadline, design: .monospaced)).foregroundColor(cream)
                }
            }
            .padding(20)
        }
        .onAppear { render() }
    }

    @MainActor private func render() {
        let renderer = ImageRenderer(content: ShareCard(gameState: gameState).frame(width: 380, height: 476))
        renderer.scale = 3
        if let ui = renderer.uiImage { shareImage = Image(uiImage: ui) }
    }
}
