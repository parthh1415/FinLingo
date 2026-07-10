//
//  LessonsView.swift
//  FinLingo
//
//  The left laptop's screen: bite-size money lessons. Each lesson teaches a concept,
//  then checks it with a short run of mixed-format questions (multiple choice, true/false,
//  tap-to-match pairs, and drag-into-buckets sorting); getting every question right on a
//  lesson's first attempt pays out in-game cash that the player spends on room upgrades.
//

import SwiftUI

// MARK: - Question model

/// The interaction style for a single question. Mirrors Duolingo's mix of formats so
/// Learn Mode isn't just a wall of multiple-choice.
enum QuestionKind {
    case multipleChoice(options: [String], correctIndex: Int)
    case trueFalse(correctAnswer: Bool)
    /// Tap a left term, then its matching right term.
    case matching(pairs: [MatchPair])
    /// Drag each item into the bucket it belongs to. `buckets` are the category labels;
    /// each item names the index of the bucket it belongs in.
    case categorize(items: [CategoryItem], buckets: [String])
}

struct MatchPair: Identifiable {
    let id = UUID()
    let left: String
    let right: String
}

struct CategoryItem: Identifiable {
    let id = UUID()
    let label: String
    /// Index into the question's `buckets` array that this item belongs to.
    let correctBucket: Int
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
                    prompt: "Drag each expense into its 50/30/20 bucket.",
                    kind: .categorize(
                        items: [
                            CategoryItem(label: "Rent", correctBucket: 0),
                            CategoryItem(label: "Streaming", correctBucket: 1),
                            CategoryItem(label: "Emergency fund", correctBucket: 2),
                            CategoryItem(label: "Extra debt payment", correctBucket: 2),
                        ],
                        buckets: ["Needs", "Wants", "Savings"]
                    )
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
                    prompt: "Drag each expense to whether the emergency fund should cover it.",
                    kind: .categorize(
                        items: [
                            CategoryItem(label: "Surprise car repair", correctBucket: 0),
                            CategoryItem(label: "Rent after a job loss", correctBucket: 0),
                            CategoryItem(label: "Black Friday TV", correctBucket: 1),
                            CategoryItem(label: "Weekend trip", correctBucket: 1),
                        ],
                        buckets: ["Use the fund", "Don't touch it"]
                    )
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
                    prompt: "True or false: starting to invest 10 years earlier, even with less money, often beats starting later with more.",
                    kind: .trueFalse(correctAnswer: true)
                ),
                Question(
                    id: "compound_interest_q3",
                    prompt: "Using the Rule of 72, match each return to how long it takes to double.",
                    kind: .matching(pairs: [
                        MatchPair(left: "6% / year", right: "~12 years"),
                        MatchPair(left: "9% / year", right: "~8 years"),
                        MatchPair(left: "12% / year", right: "~6 years"),
                    ])
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
                    prompt: "Drag each habit to what it does to your credit score.",
                    kind: .categorize(
                        items: [
                            CategoryItem(label: "Pay in full monthly", correctBucket: 0),
                            CategoryItem(label: "Keep utilization low", correctBucket: 0),
                            CategoryItem(label: "Max out the card", correctBucket: 1),
                            CategoryItem(label: "Miss a payment", correctBucket: 1),
                        ],
                        buckets: ["Helps score", "Hurts score"]
                    )
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
                        MatchPair(left: "Normal savings", right: "~0.4%"),
                        MatchPair(left: "High-yield savings", right: "~4–5%"),
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
                    prompt: "Drag each move into whether it's smart or risky when negotiating pay.",
                    kind: .categorize(
                        items: [
                            CategoryItem(label: "Research market rate", correctBucket: 0),
                            CategoryItem(label: "Counter once politely", correctBucket: 0),
                            CategoryItem(label: "Accept first offer instantly", correctBucket: 1),
                            CategoryItem(label: "Give an ultimatum", correctBucket: 1),
                        ],
                        buckets: ["Smart move", "Risky move"]
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
    /// The cash change actually applied for each answered question, in order. `0` means the
    /// question had already been scored on a previous run and so paid/charged nothing.
    @State private var deltas: [Double] = []

    private var finished: Bool { questionIndex >= lesson.questions.count }
    private var allCorrect: Bool { results.count == lesson.questions.count && results.allSatisfy { $0 } }

    /// Cash awarded for a correct answer; the wrong-answer penalty is half this, so a
    /// correct answer is always worth more than a mistake costs.
    private var perQuestionReward: Double { lesson.reward / Double(max(lesson.questions.count, 1)) }

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
                        score(correct, question: lesson.questions[questionIndex])
                    }
                    .id(lesson.questions[questionIndex].id)

                    if results.count == questionIndex + 1 {
                        deltaLabel(deltas[questionIndex])

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
    }

    /// Applies the cash change for the just-answered question — but only the first time that
    /// specific question is ever answered, so lessons can't be replayed to farm cash. Cash is
    /// clamped at 0 so a wrong answer can never push the balance negative.
    private func score(_ correct: Bool, question: Question) {
        var applied = 0.0
        if !gameState.answeredQuestions.contains(question.id) {
            let intended = correct ? perQuestionReward : -perQuestionReward / 2
            let before = gameState.cash
            gameState.cash = max(0, before + intended)
            applied = gameState.cash - before
            gameState.answeredQuestions.insert(question.id)
            // Mark the lesson done once every one of its questions has been answered.
            if lesson.questions.allSatisfy({ gameState.answeredQuestions.contains($0.id) }) {
                gameState.completedLessons.insert(lesson.id)
            }
            PersistenceController.save(gameState)
        }
        results.append(correct)
        deltas.append(applied)
    }

    /// A one-line "+$30 to your balance" / "-$15 from your balance" note under a question.
    @ViewBuilder
    private func deltaLabel(_ delta: Double) -> some View {
        if delta > 0 {
            Text("+\(CurrencyFormat.short(delta)) to your balance")
                .font(.system(.caption, design: .monospaced).weight(.bold))
                .foregroundColor(palette.term)
        } else if delta < 0 {
            Text("\(CurrencyFormat.signed(delta)) from your balance")
                .font(.system(.caption, design: .monospaced).weight(.bold))
                .foregroundColor(palette.bad)
        } else {
            Text("Already scored earlier — no change.")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(palette.dim)
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
        let correctCount = results.filter { $0 }.count
        let netChange = deltas.reduce(0, +)
        return VStack(alignment: .leading, spacing: 8) {
            Text("\(correctCount)/\(lesson.questions.count) correct")
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(allCorrect ? palette.term : palette.cream)
            if netChange > 0 {
                Text("Balance: +\(CurrencyFormat.short(netChange)) this run.")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(palette.term)
            } else if netChange < 0 {
                Text("Balance: \(CurrencyFormat.signed(netChange)) this run.")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(palette.bad)
            } else {
                Text("No change — these questions were already scored.")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(palette.dim)
            }
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
            case let .matching(pairs):
                MatchingQuestion(pairs: pairs, palette: palette, onAnswered: onAnswered)
            case let .categorize(items, buckets):
                CategorizeQuestion(items: items, buckets: buckets, palette: palette, onAnswered: onAnswered)
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

// MARK: - Matching (tap a left term, then its right pair)

private struct MatchingQuestion: View {
    let pairs: [MatchPair]
    let palette: TerminalPalette
    let onAnswered: (Bool) -> Void

    /// The right column, shuffled ONCE and held in state so re-renders don't reshuffle it
    /// out from under the player mid-question (the original bug).
    @State private var rightOrder: [MatchPair] = []
    @State private var selectedLeft: MatchPair.ID?
    @State private var matched: Set<MatchPair.ID> = []
    /// Briefly set to a right id that was just mis-tapped, so we can flash it red.
    @State private var wrongRight: MatchPair.ID?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tap a term, then its match.")
                .font(.system(.caption2, design: .monospaced)).foregroundColor(palette.dim)

            HStack(alignment: .top, spacing: 10) {
                VStack(spacing: 8) {
                    ForEach(pairs) { pair in
                        chip(pair.left,
                             state: matched.contains(pair.id) ? .matched : (selectedLeft == pair.id ? .selected : .idle)) {
                            guard !matched.contains(pair.id) else { return }
                            selectedLeft = pair.id
                        }
                    }
                }
                VStack(spacing: 8) {
                    ForEach(rightOrder) { pair in
                        chip(pair.right,
                             state: matched.contains(pair.id) ? .matched : (wrongRight == pair.id ? .wrong : .idle)) {
                            tapRight(pair.id)
                        }
                    }
                }
            }
        }
        .onAppear { if rightOrder.isEmpty { rightOrder = pairs.shuffled() } }
    }

    private enum ChipState { case idle, selected, matched, wrong }

    private func chip(_ text: String, state: ChipState, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(text).font(.system(.caption, design: .monospaced)).foregroundColor(palette.cream)
                if state == .matched { Text("✓").foregroundColor(palette.term) }
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background(for: state))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.clicky)
        .disabled(state == .matched)
    }

    private func background(for state: ChipState) -> Color {
        switch state {
        case .idle:     return Color.white.opacity(0.035)
        case .selected: return palette.amber.opacity(0.25)
        case .matched:  return palette.term.opacity(0.18)
        case .wrong:    return palette.bad.opacity(0.20)
        }
    }

    private func tapRight(_ rightID: MatchPair.ID) {
        guard let left = selectedLeft, !matched.contains(rightID) else { return }
        if left == rightID {
            matched.insert(left)
            selectedLeft = nil
            if matched.count == pairs.count { onAnswered(true) }
        } else {
            // Wrong pairing: flash the tapped right chip, then clear the selection.
            selectedLeft = nil
            wrongRight = rightID
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if wrongRight == rightID { wrongRight = nil }
            }
        }
    }
}

// MARK: - Categorize (drag each item into the correct bucket)

private struct CategorizeQuestion: View {
    let items: [CategoryItem]
    let buckets: [String]
    let palette: TerminalPalette
    let onAnswered: (Bool) -> Void

    /// itemID -> index of the bucket it's currently dropped in (nil = still in the tray).
    @State private var placement: [UUID: Int] = [:]
    /// Bucket currently under a drag, for the drop highlight.
    @State private var targeted: Int?
    /// nil until the player checks; then whether every item landed in the right bucket.
    @State private var resolved: Bool?

    private var unplaced: [CategoryItem] { items.filter { placement[$0.id] == nil } }
    private func items(in bucket: Int) -> [CategoryItem] { items.filter { placement[$0.id] == bucket } }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(buckets.indices, id: \.self) { b in
                    bucketView(b)
                }
            }

            if !unplaced.isEmpty {
                Text("Drag each into a box:")
                    .font(.system(.caption2, design: .monospaced)).foregroundColor(palette.dim)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(unplaced) { item in
                        chip(item, correctness: nil)
                            .draggable(item.id.uuidString)
                    }
                }
            } else if resolved == nil {
                Button { check() } label: {
                    Text("CHECK")
                        .font(.system(.subheadline, design: .monospaced).weight(.bold))
                        .foregroundColor(palette.screen)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(palette.amber)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.clicky)
            }

            if let resolved {
                Text(resolved ? "✓ All sorted correctly" : "✗ Some are in the wrong box")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(resolved ? palette.term : palette.bad)
            }
        }
    }

    private func bucketView(_ b: Int) -> some View {
        VStack(spacing: 6) {
            Text(buckets[b])
                .font(.system(.caption2, design: .monospaced).weight(.bold))
                .foregroundColor(palette.amber)
                .lineLimit(1).minimumScaleFactor(0.7)

            VStack(spacing: 6) {
                if items(in: b).isEmpty {
                    Text("drop here")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(palette.dim.opacity(0.6))
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(items(in: b)) { item in
                        placedChip(item, bucket: b)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .top)
            .padding(8)
            .background(targeted == b ? palette.amber.opacity(0.15) : Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(targeted == b ? palette.amber : Color.white.opacity(0.1), lineWidth: 1))
        }
        .dropDestination(for: String.self) { ids, _ in
            place(ids, into: b)
        } isTargeted: { isIn in
            targeted = isIn ? b : (targeted == b ? nil : targeted)
        }
    }

    /// A chip that's already inside a bucket. Draggable to another bucket until checked.
    @ViewBuilder
    private func placedChip(_ item: CategoryItem, bucket: Int) -> some View {
        if resolved == nil {
            chip(item, correctness: nil).draggable(item.id.uuidString)
        } else {
            chip(item, correctness: item.correctBucket == bucket)
        }
    }

    private func chip(_ item: CategoryItem, correctness: Bool?) -> some View {
        HStack(spacing: 4) {
            Text(item.label)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(palette.cream)
                .lineLimit(2).minimumScaleFactor(0.7)
            if let correctness {
                Text(correctness ? "✓" : "✗").foregroundColor(correctness ? palette.term : palette.bad)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(chipBackground(correctness))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    private func chipBackground(_ correctness: Bool?) -> Color {
        switch correctness {
        case .some(true):  return palette.term.opacity(0.18)
        case .some(false): return palette.bad.opacity(0.18)
        case .none:        return Color.white.opacity(0.06)
        }
    }

    private func place(_ ids: [String], into bucket: Int) -> Bool {
        guard resolved == nil else { return false }
        var moved = false
        for id in ids {
            if let item = items.first(where: { $0.id.uuidString == id }) {
                placement[item.id] = bucket
                moved = true
            }
        }
        targeted = nil
        return moved
    }

    private func check() {
        guard resolved == nil, unplaced.isEmpty else { return }
        let correct = items.allSatisfy { placement[$0.id] == $0.correctBucket }
        resolved = correct
        onAnswered(correct)
    }
}
