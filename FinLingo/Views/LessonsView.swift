//
//  LessonsView.swift
//  FinLingo
//
//  The left laptop's screen: bite-size money lessons. Each lesson teaches a concept,
//  then checks it with a short run of mixed-format questions (multiple choice, true/false,
//  fill-in-the-blank, ordering, matching); getting every question right on a lesson's
//  first attempt pays out in-game cash that the player spends on room upgrades.
//

import SwiftUI

// MARK: - Question model

/// The interaction style for a single question. Mirrors Duolingo's mix of formats so
/// Learn Mode isn't just a wall of multiple-choice.
enum QuestionKind {
    case multipleChoice(options: [String], correctIndex: Int)
    case trueFalse(correctAnswer: Bool)
    /// A numeric fill-in-the-blank. `unit` is a short prefix/suffix shown next to the field
    /// (e.g. "$"); `tolerance` allows answers that are close but not exact (e.g. Rule of 72
    /// estimates).
    case fillBlank(correctAnswer: Double, unit: String, tolerance: Double)
    /// Tap items into the correct sequence. `correctOrder` lists indices into `items`.
    case ordering(items: [String], correctOrder: [Int])
    case matching(pairs: [MatchPair])
}

struct MatchPair: Identifiable {
    let id = UUID()
    let left: String
    let right: String
}

struct Question: Identifiable {
    let id: String
    let prompt: String
    let kind: QuestionKind
}

struct Lesson: Identifiable {
    let id: String
    let topic: String
    let title: String
    let teach: String
    let questions: [Question]
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
            questions: [
                Question(
                    id: "budget_503020_q1",
                    prompt: "With $3,000 take-home a month, how much should go to savings + debt?",
                    kind: .multipleChoice(options: ["$300", "$600", "$900"], correctIndex: 1)
                ),
                Question(
                    id: "budget_503020_q2",
                    prompt: "Take-home pay is $2,000/month. Under the 50/30/20 rule, how much should go to \"wants\"?",
                    kind: .fillBlank(correctAnswer: 600, unit: "$", tolerance: 0)
                ),
                Question(
                    id: "budget_503020_q3",
                    prompt: "True or false: the 50/30/20 rule gives needs the smallest share of the budget.",
                    kind: .trueFalse(correctAnswer: false)
                ),
            ],
            reward: 90
        ),
        Lesson(
            id: "emergency_fund",
            topic: "SAFETY NET",
            title: "Emergency fund",
            teach: "Before investing heavily, keep 3–6 months of essential expenses somewhere safe and easy to reach. It stops one bad month from becoming debt.",
            questions: [
                Question(
                    id: "emergency_fund_q1",
                    prompt: "Your essentials are $2,000/mo. A solid starter emergency fund is about:",
                    kind: .multipleChoice(options: ["$500", "$1,000", "$6,000"], correctIndex: 2)
                ),
                Question(
                    id: "emergency_fund_q2",
                    prompt: "Essentials cost $1,500/month. A 3-month starter emergency fund is about how much?",
                    kind: .fillBlank(correctAnswer: 4500, unit: "$", tolerance: 0)
                ),
                Question(
                    id: "emergency_fund_q3",
                    prompt: "True or false: your emergency fund should be invested in the stock market so it grows faster.",
                    kind: .trueFalse(correctAnswer: false)
                ),
            ],
            reward: 90,
            practiceHint: "↳ Practice this: Simulator › Emergency fund"
        ),
        Lesson(
            id: "compound_interest",
            topic: "INVESTING",
            title: "Compound interest",
            teach: "Your earnings earn their own earnings. Time is the biggest lever — money left to grow snowballs. Rule of 72: 72 ÷ return ≈ years to double.",
            questions: [
                Question(
                    id: "compound_interest_q1",
                    prompt: "$1,000 growing ~8%/yr roughly doubles in ~9 years to about:",
                    kind: .multipleChoice(options: ["$1,080", "$2,000", "$10,000"], correctIndex: 1)
                ),
                Question(
                    id: "compound_interest_q2",
                    prompt: "Using the Rule of 72, money growing at 9%/year roughly doubles in about how many years?",
                    kind: .fillBlank(correctAnswer: 8, unit: "yrs", tolerance: 1)
                ),
                Question(
                    id: "compound_interest_q3",
                    prompt: "Same starting amount, invested for 30 years. Order these from slowest to fastest growth.",
                    kind: .ordering(
                        items: ["Invested at 2%/yr", "Invested at 5%/yr", "Invested at 9%/yr"],
                        correctOrder: [0, 1, 2]
                    )
                ),
            ],
            reward: 120,
            practiceHint: "↳ Practice this: Simulator › 401(k) calculator"
        ),
        Lesson(
            id: "credit_utilization",
            topic: "CREDIT",
            title: "Using credit well",
            teach: "Keep your card balance under ~30% of the limit and pay in full each month. That builds your score and dodges interest.",
            questions: [
                Question(
                    id: "credit_utilization_q1",
                    prompt: "Card limit is $1,000. To keep utilization healthy, stay under:",
                    kind: .multipleChoice(options: ["$300", "$700", "$1,000"], correctIndex: 0)
                ),
                Question(
                    id: "credit_utilization_q2",
                    prompt: "Card limit is $2,000. To stay under 30% utilization, keep your balance below how much?",
                    kind: .fillBlank(correctAnswer: 600, unit: "$", tolerance: 0)
                ),
                Question(
                    id: "credit_utilization_q3",
                    prompt: "True or false: carrying a balance instead of paying in full helps your credit score grow faster.",
                    kind: .trueFalse(correctAnswer: false)
                ),
            ],
            reward: 90,
            practiceHint: "↳ Practice this: Simulator › Debt payoff"
        ),
        Lesson(
            id: "high_yield_savings",
            topic: "SAVING",
            title: "Make idle cash work",
            teach: "A high-yield savings account pays roughly 10× a normal one — and it's just as safe and reachable. It's the natural home for your emergency fund.",
            questions: [
                Question(
                    id: "high_yield_savings_q1",
                    prompt: "$5,000 in a 4% high-yield account earns about how much in a year?",
                    kind: .multipleChoice(options: ["$5", "$50", "$200"], correctIndex: 2)
                ),
                Question(
                    id: "high_yield_savings_q2",
                    prompt: "Match each account type to its typical yield.",
                    kind: .matching(pairs: [
                        MatchPair(left: "Checking account", right: "~0.01%"),
                        MatchPair(left: "Normal savings account", right: "~0.4%"),
                        MatchPair(left: "High-yield savings account", right: "~4–5%"),
                    ])
                ),
                Question(
                    id: "high_yield_savings_q3",
                    prompt: "True or false: a high-yield savings account is FDIC-insured just like a normal savings account.",
                    kind: .trueFalse(correctAnswer: true)
                ),
            ],
            reward: 90,
            practiceHint: "↳ Practice this: Simulator › Invest $X/month"
        ),
        Lesson(
            id: "negotiation",
            topic: "EARNING",
            title: "Negotiating your pay",
            teach: "Your first salary sets the base every future raise builds on. Counter once, politely, with a number backed by market research — small differences compound over a career.",
            questions: [
                Question(
                    id: "negotiation_q1",
                    prompt: "A $5,000 higher starting salary, over a 40-year career, adds at least:",
                    kind: .multipleChoice(options: ["$5,000", "$50,000", "$200,000+"], correctIndex: 2)
                ),
                Question(
                    id: "negotiation_q2",
                    prompt: "Put these negotiation steps in the right order.",
                    kind: .ordering(
                        items: [
                            "Research the market salary range",
                            "Let them make the first offer",
                            "Counter once, politely, with a number",
                            "Accept, or ask for time to decide",
                        ],
                        correctOrder: [0, 1, 2, 3]
                    )
                ),
                Question(
                    id: "negotiation_q3",
                    prompt: "True or false: you should always accept the first offer to avoid seeming difficult.",
                    kind: .trueFalse(correctAnswer: false)
                ),
            ],
            reward: 120
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

// MARK: - Lessons list

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
                        .id(lesson.id) // fresh @State every time a lesson is (re)opened
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
                        .buttonStyle(.clicky)
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
                Text("\(lesson.questions.count) questions").font(.system(.caption2, design: .monospaced)).foregroundColor(dim)
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
    var bad: Color { Color(red: 0.86, green: 0.28, blue: 0.24) }
}

// MARK: - Lesson detail (teach + question run)

private struct LessonDetail: View {
    let lesson: Lesson
    @ObservedObject var gameState: GameState
    let palette: TerminalPalette
    var onBack: () -> Void

    /// Index of the question currently on screen. `== lesson.questions.count` means the
    /// run is finished and the summary/reward screen shows.
    @State private var questionIndex = 0
    /// Correctness of each question answered so far, in order.
    @State private var results: [Bool] = []

    private var alreadyDone: Bool { gameState.completedLessons.contains(lesson.id) }
    private var finished: Bool { questionIndex >= lesson.questions.count }
    private var allCorrect: Bool { results.count == lesson.questions.count && results.allSatisfy { $0 } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(lesson.topic).font(.system(.caption2, design: .monospaced).weight(.bold)).foregroundColor(palette.term)
                Text(lesson.title).font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(palette.cream)
                Text(lesson.teach).font(.system(.subheadline, design: .monospaced)).foregroundColor(palette.cream.opacity(0.85)).lineSpacing(3)

                if let hint = lesson.practiceHint {
                    Text(hint).font(.system(.caption, design: .monospaced)).foregroundColor(palette.term)
                }

                progressDots

                if finished {
                    summary
                } else {
                    QuestionCard(question: lesson.questions[questionIndex], palette: palette) { correct in
                        results.append(correct)
                    }
                    .id(lesson.questions[questionIndex].id)

                    if results.count == questionIndex + 1 {
                        Button { questionIndex += 1 } label: {
                            Text(questionIndex + 1 == lesson.questions.count ? "FINISH" : "CONTINUE")
                                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                                .foregroundColor(palette.screen)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(palette.amber)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.clicky)
                        .padding(.top, 4)
                    }
                }

                Button { onBack() } label: {
                    Text("‹ BACK").font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(palette.dim)
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .frame(maxHeight: 460)
        .onChange(of: finished) { _, isFinished in
            guard isFinished, allCorrect, !alreadyDone else { return }
            gameState.cash += lesson.reward
            gameState.completedLessons.insert(lesson.id)
            PersistenceController.save(gameState)
        }
    }

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(lesson.questions.indices, id: \.self) { i in
                Circle()
                    .fill(dotColor(for: i))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        guard index < results.count else {
            return index == questionIndex ? palette.amber.opacity(0.6) : palette.dim.opacity(0.4)
        }
        return results[index] ? palette.term : palette.bad
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 8) {
            let correctCount = results.filter { $0 }.count
            Text("\(correctCount)/\(lesson.questions.count) correct")
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(allCorrect ? palette.term : palette.cream)
            Text(allCorrect
                 ? (alreadyDone ? "Nailed it — already collected." : "Nailed it! +\(CurrencyFormat.short(lesson.reward)) added.")
                 : "Not quite everything — reopen the lesson to try again.")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(allCorrect ? palette.term : palette.dim)
        }
    }
}

// MARK: - Question card (dispatches to the right interaction for the question kind)

private struct QuestionCard: View {
    let question: Question
    let palette: TerminalPalette
    let onAnswered: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.prompt)
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(palette.amber)

            switch question.kind {
            case let .multipleChoice(options, correctIndex):
                MultipleChoiceQuestion(options: options, correctIndex: correctIndex, palette: palette, onAnswered: onAnswered)
            case let .trueFalse(correctAnswer):
                TrueFalseQuestion(correctAnswer: correctAnswer, palette: palette, onAnswered: onAnswered)
            case let .fillBlank(correctAnswer, unit, tolerance):
                FillBlankQuestion(correctAnswer: correctAnswer, unit: unit, tolerance: tolerance, palette: palette, onAnswered: onAnswered)
            case let .ordering(items, correctOrder):
                OrderingQuestion(items: items, correctOrder: correctOrder, palette: palette, onAnswered: onAnswered)
            case let .matching(pairs):
                MatchingQuestion(pairs: pairs, palette: palette, onAnswered: onAnswered)
            }
        }
    }
}

// MARK: - Multiple choice

private struct MultipleChoiceQuestion: View {
    let options: [String]
    let correctIndex: Int
    let palette: TerminalPalette
    let onAnswered: (Bool) -> Void

    @State private var picked: Int?

    var body: some View {
        VStack(spacing: 8) {
            ForEach(options.indices, id: \.self) { i in
                Button { pick(i) } label: {
                    HStack {
                        Text(options[i]).font(.system(.subheadline, design: .monospaced)).foregroundColor(palette.cream)
                        Spacer()
                        if let picked, picked == i {
                            Text(i == correctIndex ? "✓" : "✗")
                                .foregroundColor(i == correctIndex ? palette.term : palette.bad)
                        }
                    }
                    .padding(12)
                    .background(background(for: i))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .buttonStyle(.clicky)
                .disabled(picked != nil)
            }
        }
    }

    private func background(for index: Int) -> Color {
        guard let picked else { return Color.white.opacity(0.035) }
        if index == correctIndex { return palette.term.opacity(0.18) }
        if index == picked { return palette.bad.opacity(0.18) }
        return Color.white.opacity(0.035)
    }

    private func pick(_ index: Int) {
        guard picked == nil else { return }
        picked = index
        onAnswered(index == correctIndex)
    }
}

// MARK: - True / false

private struct TrueFalseQuestion: View {
    let correctAnswer: Bool
    let palette: TerminalPalette
    let onAnswered: (Bool) -> Void

    @State private var picked: Bool?

    var body: some View {
        HStack(spacing: 10) {
            option(true, label: "TRUE")
            option(false, label: "FALSE")
        }
    }

    private func option(_ value: Bool, label: String) -> some View {
        Button { pick(value) } label: {
            HStack {
                Spacer()
                Text(label).font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundColor(palette.cream)
                if let picked, picked == value {
                    Text(value == correctAnswer ? "✓" : "✗")
                        .foregroundColor(value == correctAnswer ? palette.term : palette.bad)
                }
                Spacer()
            }
            .padding(12)
            .background(background(for: value))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.clicky)
        .disabled(picked != nil)
    }

    private func background(for value: Bool) -> Color {
        guard let picked else { return Color.white.opacity(0.035) }
        if value == correctAnswer { return palette.term.opacity(0.18) }
        if value == picked { return palette.bad.opacity(0.18) }
        return Color.white.opacity(0.035)
    }

    private func pick(_ value: Bool) {
        guard picked == nil else { return }
        picked = value
        onAnswered(value == correctAnswer)
    }
}

// MARK: - Fill in the blank (numeric)

private struct FillBlankQuestion: View {
    let correctAnswer: Double
    let unit: String
    let tolerance: Double
    let palette: TerminalPalette
    let onAnswered: (Bool) -> Void

    @State private var text = ""
    @State private var submitted: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if unit == "$" {
                    Text("$").font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundColor(palette.cream)
                }
                TextField("answer", text: $text)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(palette.cream)
                    .padding(10)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .disabled(submitted != nil)
                if unit != "$" {
                    Text(unit).font(.system(.subheadline, design: .monospaced)).foregroundColor(palette.dim)
                }

                if submitted == nil {
                    Button("CHECK") { check() }
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundColor(palette.screen)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(palette.amber)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .buttonStyle(.clicky)
                        .disabled(Double(text) == nil)
                }
            }

            if let submitted {
                Text(submitted ? "✓ Correct" : "✗ Correct answer: \(unit == "$" ? "$" : "")\(formatted(correctAnswer))\(unit == "$" ? "" : " \(unit)")")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(submitted ? palette.term : palette.bad)
            }
        }
    }

    private func formatted(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(v)
    }

    private func check() {
        guard submitted == nil, let value = Double(text) else { return }
        let correct = abs(value - correctAnswer) <= tolerance
        submitted = correct
        onAnswered(correct)
    }
}

// MARK: - Ordering (tap items into sequence)

private struct OrderingQuestion: View {
    let items: [String]
    let correctOrder: [Int]
    let palette: TerminalPalette
    let onAnswered: (Bool) -> Void

    /// Indices into `items`, in the order the player tapped them.
    @State private var tapped: [Int] = []
    @State private var resolved: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items.indices, id: \.self) { i in
                Button { tap(i) } label: {
                    HStack {
                        if let position = tapped.firstIndex(of: i) {
                            Text("\(position + 1)")
                                .font(.system(.caption, design: .monospaced).weight(.bold))
                                .foregroundColor(palette.screen)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(palette.amber))
                        }
                        Text(items[i]).font(.system(.subheadline, design: .monospaced)).foregroundColor(palette.cream)
                        Spacer()
                    }
                    .padding(12)
                    .background(rowBackground(i))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .buttonStyle(.clicky)
                .disabled(resolved != nil || tapped.contains(i))
            }

            if resolved == nil, !tapped.isEmpty {
                Button("RESET") { tapped = [] }
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundColor(palette.dim)
                    .buttonStyle(.clicky)
            }

            if let resolved {
                Text(resolved ? "✓ Correct order" : "✗ Not quite the right order")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(resolved ? palette.term : palette.bad)
            }
        }
    }

    private func rowBackground(_ i: Int) -> Color {
        guard let resolved else { return Color.white.opacity(0.035) }
        return resolved ? palette.term.opacity(0.12) : palette.bad.opacity(0.12)
    }

    private func tap(_ i: Int) {
        guard resolved == nil, !tapped.contains(i) else { return }
        tapped.append(i)
        guard tapped.count == items.count else { return }
        let correct = tapped == correctOrder
        resolved = correct
        onAnswered(correct)
    }
}

// MARK: - Matching (tap a left item, then its right pair)

private struct MatchingQuestion: View {
    let pairs: [MatchPair]
    let palette: TerminalPalette
    let onAnswered: (Bool) -> Void

    private let leftOrder: [MatchPair]
    private let rightOrder: [MatchPair]

    @State private var selectedLeft: MatchPair.ID?
    @State private var matched: Set<MatchPair.ID> = []

    init(pairs: [MatchPair], palette: TerminalPalette, onAnswered: @escaping (Bool) -> Void) {
        self.pairs = pairs
        self.palette = palette
        self.onAnswered = onAnswered
        self.leftOrder = pairs
        self.rightOrder = pairs.shuffled()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 8) {
                ForEach(leftOrder) { pair in
                    chip(pair.left, isMatched: matched.contains(pair.id), isSelected: selectedLeft == pair.id) {
                        guard !matched.contains(pair.id) else { return }
                        selectedLeft = pair.id
                    }
                }
            }
            VStack(spacing: 8) {
                ForEach(rightOrder) { pair in
                    chip(pair.right, isMatched: matched.contains(pair.id), isSelected: false) {
                        guard let left = selectedLeft, !matched.contains(pair.id) else { return }
                        attemptMatch(left: left, right: pair.id)
                    }
                }
            }
        }
    }

    private func chip(_ text: String, isMatched: Bool, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(palette.cream)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(isMatched ? palette.term.opacity(0.18) : isSelected ? palette.amber.opacity(0.25) : Color.white.opacity(0.035))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.clicky)
        .disabled(isMatched)
    }

    private func attemptMatch(left: MatchPair.ID, right: MatchPair.ID) {
        if left == right {
            matched.insert(left)
            selectedLeft = nil
            if matched.count == pairs.count { onAnswered(true) }
        } else {
            selectedLeft = nil // wrong pairing — deselect and let them try again
        }
    }
}
