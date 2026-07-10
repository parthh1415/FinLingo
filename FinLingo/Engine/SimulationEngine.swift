//
//  SimulationEngine.swift
//  FinLingo
//
//  The heart of the game: a month-by-month life simulation. Time advances (one month every
//  few seconds), each month applies your real cash flow — income in, spending out, the rest
//  split to savings/investments which compound — and life events interrupt with choices that
//  bend the trajectory. Net worth is the running score.
//

import Foundation
import Combine

final class SimulationEngine: ObservableObject {
    @Published private(set) var monthIndex: Int
    @Published var isRunning: Bool = true
    @Published var speed: Int = 1                 // 1× or 2×
    @Published var pendingEvent: LifeEvent?

    private let gameState: GameState
    private var cancellable: AnyCancellable?
    private var accumulator: Double = 0
    private var usedEventIds: Set<String> = []

    private let secondsPerMonth: Double = 5.0
    private let tickInterval: Double = 0.1
    private let monthlyReturn = FinRates.annualReturn / 12
    private let debtMonthlyRate = 0.18 / 12        // ~18% APR on carried debt
    private let maxHistory = 360                   // 30 years of monthly points
    private let eventEveryMonths = 6

    init(gameState: GameState) {
        self.gameState = gameState
        self.monthIndex = gameState.monthIndex
    }

    /// Current age including the months simulated so far.
    var age: Double { Double(gameState.age) + Double(monthIndex) / 12.0 }

    /// Fraction (0…1) toward the next month, for a smooth progress indicator.
    var monthProgress: Double { min(accumulator / secondsPerMonth, 1) }

    // MARK: - Clock

    func start() {
        guard cancellable == nil else { return }
        // Seed one history point so the curve isn't empty at month 0.
        if gameState.netWorthHistory.isEmpty { gameState.netWorthHistory = [gameState.netWorth] }
        cancellable = Timer.publish(every: tickInterval, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func stop() { cancellable?.cancel(); cancellable = nil }

    func togglePause() { isRunning.toggle() }
    func cycleSpeed() { speed = speed == 1 ? 2 : 1 }

    private func tick() {
        guard isRunning, pendingEvent == nil else { return }
        accumulator += tickInterval * Double(speed)
        while accumulator >= secondsPerMonth {
            accumulator -= secondsPerMonth
            stepMonth()
            if pendingEvent != nil { accumulator = 0; break }   // hold time while deciding
        }
    }

    // MARK: - Month step

    private func stepMonth() {
        applyMonthlyFlow()
        monthIndex += 1
        gameState.monthIndex = monthIndex
        recordNetWorth()
        if monthIndex % 3 == 0 { PersistenceController.save(gameState) }
        maybeTriggerEvent()
    }

    private func applyMonthlyFlow() {
        let income = max(0, gameState.monthlyIncome)
        let alloc = min(max(gameState.investAllocation, 0), 1)
        let invested = income * alloc

        // Debt compounds too — that's the whole point of "don't carry a balance."
        gameState.debt += gameState.debt * debtMonthlyRate

        // Existing investments grow first, then this month's contribution lands.
        gameState.investedBalance += gameState.investedBalance * monthlyReturn
        gameState.investedBalance += invested

        // Whatever's left after investing and spending flows to cash; a shortfall becomes debt.
        var cash = gameState.cash + (income - invested - max(0, gameState.monthlySpending))
        if cash < 0 { gameState.debt += -cash; cash = 0 }
        gameState.cash = cash
    }

    private func recordNetWorth() {
        gameState.netWorthHistory.append(gameState.netWorth)
        if gameState.netWorthHistory.count > maxHistory {
            gameState.netWorthHistory.removeFirst(gameState.netWorthHistory.count - maxHistory)
        }
    }

    // MARK: - Events

    private func maybeTriggerEvent() {
        guard monthIndex > 0, monthIndex % eventEveryMonths == 0 else { return }
        var available = LifeEventCatalog.all.filter { !usedEventIds.contains($0.id) }
        // Recycle the catalog once it's exhausted so events keep coming for the full run.
        if available.isEmpty { usedEventIds.removeAll(); available = LifeEventCatalog.all }
        guard let event = available.randomElement() else { return }
        pendingEvent = event
    }

    /// Apply a chosen outcome, then resume the clock.
    func resolve(_ choice: LifeEvent.Choice) {
        var cash = gameState.cash + choice.cash
        if cash < 0 { gameState.debt += -cash; cash = 0 }
        gameState.cash = cash
        gameState.debt = max(0, gameState.debt + choice.debt)
        gameState.monthlyIncome = max(0, gameState.monthlyIncome + choice.income)
        gameState.investedBalance = max(0, gameState.investedBalance + choice.invested)

        if let id = pendingEvent?.id { usedEventIds.insert(id) }
        PersistenceController.save(gameState)
        pendingEvent = nil
    }
}
