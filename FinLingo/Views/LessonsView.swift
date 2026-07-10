//
//  LessonsView.swift
//  FinLingo
//
//  The left laptop's screen: bite-size money lessons. Each lesson teaches a concept,
//  then checks it with one question; a first correct answer pays out in-game cash that
//  the player spends on room upgrades.
//

import SwiftUI

struct Lesson: Identifiable {
    let id: String
    let topic: String
    let title: String
    let teach: String
    let question: String
    let options: [String]
    let correctIndex: Int
    let reward: Double
    var practiceHint: String? = nil // points to the matching Simulator tool
}

enum LessonContent {
    static let all: [Lesson] = [
        Lesson(
            id: "budget_503020",
            topic: "BUDGETING",
            title: "The 50/30/20 rule",
            teach: "A simple way to split your take-home pay: 50% to needs (rent, food, bills), 30% to wants, and 20% to savings and paying down debt.",
            question: "With $3,000 take-home a month, how much should go to savings + debt?",
            options: ["$300", "$600", "$900"],
            correctIndex: 1,
            reward: 75
        ),
        Lesson(
            id: "emergency_fund",
            topic: "SAFETY NET",
            title: "Emergency fund",
            teach: "Before investing heavily, keep 3–6 months of essential expenses somewhere safe and easy to reach. It stops one bad month from becoming debt.",
            question: "Your essentials are $2,000/mo. A solid starter emergency fund is about:",
            options: ["$500", "$1,000", "$6,000"],
            correctIndex: 2,
            reward: 75,
            practiceHint: "↳ Practice this: Simulator › Emergency fund"
        ),
        Lesson(
            id: "compound_interest",
            topic: "INVESTING",
            title: "Compound interest",
            teach: "Your earnings earn their own earnings. Time is the biggest lever — money left to grow snowballs. Rule of 72: 72 ÷ return ≈ years to double.",
            question: "$1,000 growing ~8%/yr roughly doubles in ~9 years to about:",
            options: ["$1,080", "$2,000", "$10,000"],
            correctIndex: 1,
            reward: 100,
            practiceHint: "↳ Practice this: Simulator › 401(k) calculator"
        ),
        Lesson(
            id: "credit_utilization",
            topic: "CREDIT",
            title: "Using credit well",
            teach: "Keep your card balance under ~30% of the limit and pay in full each month. That builds your score and dodges interest.",
            question: "Card limit is $1,000. To keep utilization healthy, stay under:",
            options: ["$300", "$700", "$1,000"],
            correctIndex: 0,
            reward: 75,
            practiceHint: "↳ Practice this: Simulator › Debt payoff"
        ),
        Lesson(
            id: "high_yield_savings",
            topic: "SAVING",
            title: "Make idle cash work",
            teach: "A high-yield savings account pays roughly 10× a normal one — and it's just as safe and reachable. It's the natural home for your emergency fund.",
            question: "$5,000 in a 4% high-yield account earns about how much in a year?",
            options: ["$5", "$50", "$200"],
            correctIndex: 2,
            reward: 75,
            practiceHint: "↳ Practice this: Simulator › Invest $X/month"
        ),
        Lesson(
            id: "negotiation",
            topic: "EARNING",
            title: "Negotiating your pay",
            teach: "Your first salary sets the base every future raise builds on. Counter once, politely, with a number backed by market research — small differences compound over a career.",
            question: "A $5,000 higher starting salary, over a 40-year career, adds at least:",
            options: ["$5,000", "$50,000", "$200,000+"],
            correctIndex: 2,
            reward: 100
        ),
    ]

    /// Lessons whose topic matches the player's goals float to the top, so the tree
    /// feels personalized without hiding anything.
    static func ordered(for goals: [String]) -> [Lesson] {
        let priorityByGoal: [String: Set<String>] = [
            "start_investing": ["compound_interest", "high_yield_savings"],
            "pay_off_debt": ["credit_utilization"],
            "emergency_fund": ["emergency_fund", "high_yield_savings"],
            "buy_home": ["budget_503020", "high_yield_savings"],
            "retirement": ["compound_interest"],
            "travel": ["budget_503020"],
        ]
        let prioritized = goals.reduce(into: Set<String>()) { $0.formUnion(priorityByGoal[$1] ?? []) }
        return all.enumerated().sorted { lhs, rhs in
            let l = prioritized.contains(lhs.element.id)
            let r = prioritized.contains(rhs.element.id)
            if l != r { return l }        // prioritized first
            return lhs.offset < rhs.offset // otherwise keep authored order
        }.map(\.element)
    }
}

struct LessonsView: View {
    @ObservedObject var gameState: GameState
    var onClose: () -> Void

    @State private var selected: Lesson?

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
                if let lesson = selected {
                    LessonDetail(lesson: lesson, gameState: gameState, palette: palette) { selected = nil }
                } else {
                    lessonList
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
            Text("learn.finlingo").font(.system(.footnote, design: .monospaced)).foregroundColor(dim)
            Spacer()
            Text(CurrencyFormat.short(gameState.cash))
                .font(.system(.headline, design: .monospaced).weight(.bold))
                .foregroundColor(amber).monospacedDigit()
        }
        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
    }

    private var lessonList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(LessonContent.ordered(for: gameState.goals)) { lesson in
                    Button { selected = lesson } label: { lessonRow(lesson) }
                        .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .frame(maxHeight: 420)
    }

    private func lessonRow(_ lesson: Lesson) -> some View {
        let done = gameState.completedLessons.contains(lesson.id)
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(lesson.topic).font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(term)
                Text(lesson.title).font(.system(.headline, design: .monospaced)).foregroundColor(cream)
            }
            Spacer(minLength: 8)
            if done {
                Text("DONE ✓").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(term)
            } else {
                Text("+\(CurrencyFormat.short(lesson.reward))")
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

struct TerminalPalette {
    let screen, edge, cream, amber, term, dim: Color
}

private struct LessonDetail: View {
    let lesson: Lesson
    @ObservedObject var gameState: GameState
    let palette: TerminalPalette
    var onBack: () -> Void

    @State private var picked: Int?

    private var alreadyDone: Bool { gameState.completedLessons.contains(lesson.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(lesson.topic).font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(palette.term)
                Text(lesson.title).font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(palette.cream)
                Text(lesson.teach).font(.system(.subheadline, design: .monospaced)).foregroundColor(palette.cream.opacity(0.85)).lineSpacing(3)

                if let hint = lesson.practiceHint {
                    Text(hint).font(.system(.caption, design: .monospaced)).foregroundColor(palette.term)
                }

                Text(lesson.question).font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundColor(palette.amber).padding(.top, 4)

                ForEach(lesson.options.indices, id: \.self) { i in
                    Button { pick(i) } label: {
                        HStack {
                            Text(lesson.options[i]).font(.system(.subheadline, design: .monospaced)).foregroundColor(palette.cream)
                            Spacer()
                            if let picked, picked == i {
                                Text(i == lesson.correctIndex ? "✓" : "✗")
                                    .foregroundColor(i == lesson.correctIndex ? palette.term : Color(red: 0.86, green: 0.28, blue: 0.24))
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

                if let picked {
                    let correct = picked == lesson.correctIndex
                    Text(correct
                         ? (alreadyDone ? "Correct — already collected." : "Correct! +\(CurrencyFormat.short(lesson.reward)) added.")
                         : "Not quite — the highlighted answer is right. Try the next lesson.")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(correct ? palette.term : palette.dim)
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
        if index == lesson.correctIndex { return palette.term.opacity(0.18) }
        if index == picked { return Color(red: 0.86, green: 0.28, blue: 0.24).opacity(0.18) }
        return Color.white.opacity(0.035)
    }

    private func pick(_ index: Int) {
        guard picked == nil else { return }
        picked = index
        if index == lesson.correctIndex, !alreadyDone {
            gameState.cash += lesson.reward
            gameState.completedLessons.insert(lesson.id)
            PersistenceController.save(gameState)
        }
    }
}
