import Combine
import Foundation

/// The persistent player/company state.
///
/// Per the design (§5), `cash` is stored as a `Double` so per-frame fractional income
/// accrues correctly; it is displayed floored. Compute is NOT stored — it is a derived
/// rate computed each frame from `ownedGear` (see EconomyEngine).
final class GameState: ObservableObject, Codable {
    @Published var companyName: String
    @Published var cash: Double
    /// How many of each gear the player owns, keyed by GearDefinition.id.
    @Published var ownedGear: [String: Int]
    /// Which stage the camera is centered on (0 = dorm).
    @Published var currentStageIndex: Int
    /// Highest stage index unlocked so far.
    @Published var unlockedStageIndex: Int
    /// Timestamp of when the game was last seen, used for offline earnings.
    @Published var lastSeen: Date
    /// Lesson ids the player has already completed, so a lesson pays out only once.
    @Published var completedLessons: Set<String>
    /// Simulator challenge ids the player has already run, so each pays out only once.
    @Published var completedChallenges: Set<String>
    /// Individual lesson-question ids the player has already answered, so each question
    /// rewards (correct) or penalizes (wrong) the cash balance exactly once ever.
    @Published var answeredQuestions: Set<String>

    // MARK: - Player profile (set once at onboarding; personalizes the experience)

    /// Whether the player has finished the opening profile setup.
    @Published var hasOnboarded: Bool
    /// Whether the player has seen the one-time coach tour that runs after onboarding.
    @Published var hasSeenTutorial: Bool
    /// The player's monthly income — the sole source of passive earnings (design §6).
    @Published var monthlyIncome: Double
    /// Typical monthly spending; context for budgeting lessons.
    @Published var monthlySpending: Double
    /// Goal ids the player picked at onboarding; used to order the lessons.
    @Published var goals: [String]
    /// Household context id (just_me / partner / kids / supporting_family).
    @Published var household: String
    /// Side-hustle ids the player has taken on; each permanently raises monthly income.
    @Published var sideHustles: [String]
    /// Whether the player has already won their one salary negotiation raise.
    @Published var negotiationDone: Bool
    /// Fraction (0...1) of income routed to investing; the rest lands as spendable cash.
    @Published var investAllocation: Double
    /// The invested pot, which compounds over time. Part of net worth.
    @Published var investedBalance: Double
    /// A rolling sample of net worth over time, used to draw the shareable progress curve.
    @Published var netWorthHistory: [Double]

    // MARK: - Personal details (entered at onboarding; drive every calculation)

    /// The player's first name, for a personal touch throughout.
    @Published var playerName: String
    /// Current age — the Future You projection starts here.
    @Published var age: Int
    /// The player's job title, shown on the Career screen.
    @Published var jobTitle: String
    /// Existing debt (loans/cards); subtracts from net worth and pre-fills the debt tool.
    @Published var debt: Double

    /// Everything the player is worth: spendable cash plus investments, minus debt.
    var netWorth: Double { cash + investedBalance - debt }

    init(
        companyName: String = "Dorm Room Labs",
        cash: Double = 500,
        ownedGear: [String: Int] = [:],
        currentStageIndex: Int = 0,
        unlockedStageIndex: Int = 0,
        lastSeen: Date = Date(),
        completedLessons: Set<String> = [],
        completedChallenges: Set<String> = [],
        answeredQuestions: Set<String> = [],
        hasOnboarded: Bool = false,
        hasSeenTutorial: Bool = false,
        monthlyIncome: Double = 0,
        monthlySpending: Double = 0,
        goals: [String] = [],
        household: String = "just_me",
        sideHustles: [String] = [],
        negotiationDone: Bool = false,
        investAllocation: Double = 0,
        investedBalance: Double = 0,
        netWorthHistory: [Double] = [],
        playerName: String = "",
        age: Int = 25,
        jobTitle: String = "",
        debt: Double = 0
    ) {
        self.companyName = companyName
        self.cash = cash
        self.ownedGear = ownedGear
        self.currentStageIndex = currentStageIndex
        self.unlockedStageIndex = unlockedStageIndex
        self.lastSeen = lastSeen
        self.completedLessons = completedLessons
        self.completedChallenges = completedChallenges
        self.answeredQuestions = answeredQuestions
        self.hasOnboarded = hasOnboarded
        self.hasSeenTutorial = hasSeenTutorial
        self.monthlyIncome = monthlyIncome
        self.monthlySpending = monthlySpending
        self.goals = goals
        self.household = household
        self.sideHustles = sideHustles
        self.negotiationDone = negotiationDone
        self.investAllocation = investAllocation
        self.investedBalance = investedBalance
        self.netWorthHistory = netWorthHistory
        self.playerName = playerName
        self.age = age
        self.jobTitle = jobTitle
        self.debt = debt
    }

    // MARK: - Convenience

    /// Total count of a given gear id currently owned.
    func ownedCount(of gearID: String) -> Int {
        ownedGear[gearID, default: 0]
    }

    /// Whether the player owns at least one piece of compute gear (gates overclocking).
    var ownsAnyGear: Bool {
        ownedGear.values.contains { $0 > 0 }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case companyName, cash, ownedGear, currentStageIndex, unlockedStageIndex, lastSeen
        case completedLessons, completedChallenges, answeredQuestions
        case hasOnboarded, hasSeenTutorial, monthlyIncome, monthlySpending, goals, household
        case sideHustles, negotiationDone
        case investAllocation, investedBalance, netWorthHistory
        case playerName, age, jobTitle, debt
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            companyName: try c.decode(String.self, forKey: .companyName),
            cash: try c.decode(Double.self, forKey: .cash),
            ownedGear: try c.decode([String: Int].self, forKey: .ownedGear),
            currentStageIndex: try c.decode(Int.self, forKey: .currentStageIndex),
            unlockedStageIndex: try c.decode(Int.self, forKey: .unlockedStageIndex),
            lastSeen: try c.decode(Date.self, forKey: .lastSeen),
            // decodeIfPresent so saves from before these fields existed still load.
            completedLessons: try c.decodeIfPresent(Set<String>.self, forKey: .completedLessons) ?? [],
            completedChallenges: try c.decodeIfPresent(Set<String>.self, forKey: .completedChallenges) ?? [],
            answeredQuestions: try c.decodeIfPresent(Set<String>.self, forKey: .answeredQuestions) ?? [],
            hasOnboarded: try c.decodeIfPresent(Bool.self, forKey: .hasOnboarded) ?? false,
            hasSeenTutorial: try c.decodeIfPresent(Bool.self, forKey: .hasSeenTutorial) ?? false,
            monthlyIncome: try c.decodeIfPresent(Double.self, forKey: .monthlyIncome) ?? 0,
            monthlySpending: try c.decodeIfPresent(Double.self, forKey: .monthlySpending) ?? 0,
            goals: try c.decodeIfPresent([String].self, forKey: .goals) ?? [],
            household: try c.decodeIfPresent(String.self, forKey: .household) ?? "just_me",
            sideHustles: try c.decodeIfPresent([String].self, forKey: .sideHustles) ?? [],
            negotiationDone: try c.decodeIfPresent(Bool.self, forKey: .negotiationDone) ?? false,
            investAllocation: try c.decodeIfPresent(Double.self, forKey: .investAllocation) ?? 0,
            investedBalance: try c.decodeIfPresent(Double.self, forKey: .investedBalance) ?? 0,
            netWorthHistory: try c.decodeIfPresent([Double].self, forKey: .netWorthHistory) ?? [],
            playerName: try c.decodeIfPresent(String.self, forKey: .playerName) ?? "",
            age: try c.decodeIfPresent(Int.self, forKey: .age) ?? 25,
            jobTitle: try c.decodeIfPresent(String.self, forKey: .jobTitle) ?? "",
            debt: try c.decodeIfPresent(Double.self, forKey: .debt) ?? 0
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(companyName, forKey: .companyName)
        try c.encode(cash, forKey: .cash)
        try c.encode(ownedGear, forKey: .ownedGear)
        try c.encode(currentStageIndex, forKey: .currentStageIndex)
        try c.encode(unlockedStageIndex, forKey: .unlockedStageIndex)
        try c.encode(lastSeen, forKey: .lastSeen)
        try c.encode(completedLessons, forKey: .completedLessons)
        try c.encode(completedChallenges, forKey: .completedChallenges)
        try c.encode(answeredQuestions, forKey: .answeredQuestions)
        try c.encode(hasOnboarded, forKey: .hasOnboarded)
        try c.encode(hasSeenTutorial, forKey: .hasSeenTutorial)
        try c.encode(monthlyIncome, forKey: .monthlyIncome)
        try c.encode(monthlySpending, forKey: .monthlySpending)
        try c.encode(goals, forKey: .goals)
        try c.encode(household, forKey: .household)
        try c.encode(sideHustles, forKey: .sideHustles)
        try c.encode(negotiationDone, forKey: .negotiationDone)
        try c.encode(investAllocation, forKey: .investAllocation)
        try c.encode(investedBalance, forKey: .investedBalance)
        try c.encode(netWorthHistory, forKey: .netWorthHistory)
        try c.encode(playerName, forKey: .playerName)
        try c.encode(age, forKey: .age)
        try c.encode(jobTitle, forKey: .jobTitle)
        try c.encode(debt, forKey: .debt)
    }
}
