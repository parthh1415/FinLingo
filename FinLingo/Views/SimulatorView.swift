//
//  SimulatorView.swift
//  FinLingo
//
//  The right laptop's screen: practice money moves against real historical data. The player
//  makes a call, sees what actually happened, and earns in-game cash for playing it out.
//

import SwiftUI

struct Challenge: Identifiable {
    let id: String
    let title: String
    let setup: String
    let question: String
    let options: [String]
    let correctIndex: Int
    /// Shown after the player answers — the real-world outcome.
    let outcome: String
    let reward: Double
}

enum ChallengeContent {
    static let all: [Challenge] = [
        Challenge(
            id: "sp500_decade",
            title: "Index funds over a decade",
            setup: "You invest $1,000 in an S&P 500 index fund at the start of 2010 and don't touch it, dividends reinvested.",
            question: "Roughly what is it worth 10 years later, at the start of 2020?",
            options: ["$1,300", "$2,100", "$3,500"],
            correctIndex: 2,
            outcome: "About $3,500. The S&P 500's total return over the 2010s was roughly 250% — near 13% a year. Staying invested and reinvesting dividends is what compounding looks like.",
            reward: 150
        ),
        Challenge(
            id: "cash_vs_hysa",
            title: "Cash vs. high-yield savings",
            setup: "You set aside $1,000 for 5 years. Option A leaves it as cash. Option B puts it in a 4% high-yield savings account.",
            question: "How much MORE does Option B have after 5 years?",
            options: ["$0", "About $50", "About $217"],
            correctIndex: 2,
            outcome: "About $217. At 4% compounding, $1,000 becomes ~$1,217 in 5 years. Idle cash also quietly loses value to inflation — an easy win most people skip.",
            reward: 100
        ),
        Challenge(
            id: "inflation_bite",
            title: "What inflation does",
            setup: "You keep $1,000 in a jar. Over the last few years U.S. inflation averaged roughly 4% a year.",
            question: "After ~3 years, what can that $1,000 buy, in today's money?",
            options: ["About $1,120", "About $1,000", "About $890"],
            correctIndex: 2,
            outcome: "About $890. At ~4% inflation for 3 years, cash loses roughly 11% of its buying power. Money that isn't at least keeping pace is shrinking.",
            reward: 100
        ),
        Challenge(
            id: "buy_the_crash",
            title: "Staying in through a crash",
            setup: "March 2020: COVID crashes the market about 34% in a few weeks. It's scary. You keep your money invested and keep adding a little each month.",
            question: "Where was the S&P 500 about a year later, in early 2021?",
            options: ["Still deep in the red", "Roughly back to even", "At new all-time highs"],
            correctIndex: 2,
            outcome: "New all-time highs. The market recovered its losses by August 2020 and kept climbing. Selling in the panic locked in losses; staying invested — and buying while it was down — paid off.",
            reward: 150
        ),
    ]
}

struct SimulatorView: View {
    @ObservedObject var gameState: GameState
    var onClose: () -> Void

    @State private var selected: Challenge?

    private let scrim = Color.black.opacity(0.6)
    private let screen = Color(red: 0.055, green: 0.075, blue: 0.09)
    private let edge = Color(red: 0.83, green: 0.66, blue: 0.33)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)
    private var dim: Color { cream.opacity(0.45) }

    var body: some View {
        ZStack {
            scrim.ignoresSafeArea().contentShape(Rectangle()).onTapGesture { onClose() }

            VStack(spacing: 0) {
                titleBar
                Rectangle().fill(edge.opacity(0.35)).frame(height: 1)
                if let challenge = selected {
                    ChallengeDetail(challenge: challenge, gameState: gameState, palette: palette) { selected = nil }
                } else {
                    challengeList
                }
                Rectangle().fill(edge.opacity(0.35)).frame(height: 1)
                footer
            }
            .background(screen)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(edge.opacity(0.75), lineWidth: 2))
            .shadow(color: edge.opacity(0.25), radius: 22, y: 10)
            .contentShape(Rectangle())
            .onTapGesture { }
            .padding(.horizontal, 20)
        }
        .font(.system(.body, design: .monospaced))
    }

    private var palette: TerminalPalette {
        TerminalPalette(screen: screen, edge: edge, cream: cream, amber: amber, term: term, dim: dim)
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
            Text(CurrencyFormat.short(gameState.cash))
                .font(.system(.headline, design: .monospaced).weight(.bold))
                .foregroundColor(amber).monospacedDigit()
        }
        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
    }

    private var challengeList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Text("> practice with real market history")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(term.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(ChallengeContent.all) { challenge in
                    Button { selected = challenge } label: { challengeRow(challenge) }
                        .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .frame(maxHeight: 420)
    }

    private func challengeRow(_ challenge: Challenge) -> some View {
        let done = gameState.completedChallenges.contains(challenge.id)
        return HStack(spacing: 12) {
            Text(challenge.title).font(.system(.headline, design: .monospaced)).foregroundColor(cream)
            Spacer(minLength: 8)
            if done {
                Text("DONE ✓").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(term)
            } else {
                Text("+\(CurrencyFormat.short(challenge.reward))")
                    .font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundColor(amber)
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
}

private struct ChallengeDetail: View {
    let challenge: Challenge
    @ObservedObject var gameState: GameState
    let palette: TerminalPalette
    var onBack: () -> Void

    @State private var picked: Int?

    private var alreadyDone: Bool { gameState.completedChallenges.contains(challenge.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(challenge.title).font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(palette.cream)
                Text(challenge.setup).font(.system(.subheadline, design: .monospaced)).foregroundColor(palette.cream.opacity(0.85)).lineSpacing(3)
                Text(challenge.question).font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundColor(palette.amber)

                ForEach(challenge.options.indices, id: \.self) { i in
                    Button { pick(i) } label: {
                        HStack {
                            Text(challenge.options[i]).font(.system(.subheadline, design: .monospaced)).foregroundColor(palette.cream)
                            Spacer()
                            if let picked, picked == i {
                                Text(i == challenge.correctIndex ? "✓" : "✗")
                                    .foregroundColor(i == challenge.correctIndex ? palette.term : Color(red: 0.86, green: 0.28, blue: 0.24))
                            }
                        }
                        .padding(12)
                        .background(background(for: i))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(picked != nil)
                }

                if picked != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WHAT REALLY HAPPENED").font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(palette.term)
                        Text(challenge.outcome).font(.system(.caption, design: .monospaced)).foregroundColor(palette.cream.opacity(0.85)).lineSpacing(3)
                        if !alreadyDone {
                            Text("+\(CurrencyFormat.short(challenge.reward)) earned")
                                .font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(palette.amber)
                        }
                    }
                    .padding(12)
                    .background(palette.term.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Button { onBack() } label: {
                    Text("‹ BACK").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(palette.dim)
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .frame(maxHeight: 460)
    }

    private func background(for index: Int) -> Color {
        guard let picked else { return Color.white.opacity(0.035) }
        if index == challenge.correctIndex { return palette.term.opacity(0.18) }
        if index == picked { return Color(red: 0.86, green: 0.28, blue: 0.24).opacity(0.18) }
        return Color.white.opacity(0.035)
    }

    private func pick(_ index: Int) {
        guard picked == nil else { return }
        picked = index
        // Playing a challenge through pays out once, whatever the answer — the lesson is in seeing the real outcome.
        if !alreadyDone {
            gameState.cash += challenge.reward
            gameState.completedChallenges.insert(challenge.id)
            PersistenceController.save(gameState)
        }
    }
}
