//
//  EconomyEngine.swift
//  FinLingo
//
//  Drives the core idle/active economy loop: passive compute->cash accrual,
//  the tap-driven "heat" boost system, the overheat throttle penalty, gear
//  purchasing, and offline earnings. See design spec §6 / §6a.
//

import Foundation
import Combine
import CoreGraphics

/// Single source of truth for the assumed long-run investment return, used by the in-game
/// compounding and by the Simulator's calculators so they always agree.
enum FinRates {
    static let annualReturn = 0.07
}

/// The economic simulation for a single play session.
///
/// `EconomyEngine` observes a `GameState` and a `currentStage`, and is ticked
/// once per frame via `update(dt:)`. It exposes published `heat`,
/// `boostMultiplier`, and `isOverheated` values for the UI to render, and
/// mutates `gameState` (cash, owned gear, lastSeen) as the game runs.
final class EconomyEngine: ObservableObject {

    // MARK: - Published state

    /// Current thermal load, clamped to `0...100`. Tapping adds heat; idle time
    /// cools it. Reaching 100 triggers an overheat.
    @Published private(set) var heat: Double = 0

    /// Multiplier applied to `cashPerSec`. `1.0` when cold, scaling up to
    /// `maxBoost` as heat rises, and pinned to `throttleMultiplier` while
    /// overheated.
    @Published private(set) var boostMultiplier: Double = 1.0

    /// `true` while the rig is in its post-overheat throttle penalty window.
    @Published private(set) var isOverheated: Bool = false

    // MARK: - Configuration

    /// The active stage. Settable so the host can swap stages without rebuilding
    /// the engine; defaults to the stage supplied at init. `@Published` so the
    /// marketplace/HUD refresh when the player advances to a new stage.
    @Published var currentStage: StageDefinition

    // MARK: - Tuning constants

    /// Heat added per tap.
    private let tapHeat: Double = 8
    /// Heat shed per second while not overheated.
    private let coolRate: Double = 18
    /// Maximum boost multiplier reached at full (100) heat.
    private let maxBoost: Double = 4.0
    /// Heat level considered the "redline" warning threshold.
    private let redline: Double = 90
    /// Multiplier applied while throttled (overheated).
    private let throttleMultiplier: Double = 0.5
    /// Duration, in seconds, of the throttle penalty after an overheat.
    private let throttleSeconds: Double = 12
    /// Maximum amount of offline time (seconds) credited on return.
    private let offlineCapSeconds: Double = 8 * 3600
    /// Seconds in a year, for compounding invested money.
    private let secondsPerYear: Double = 365 * 24 * 3600
    /// Illustrative annual return applied to the invested balance.
    private let annualReturn: Double = FinRates.annualReturn

    // MARK: - Private state

    /// The game state this engine reads from and writes to.
    private let gameState: GameState
    /// Seconds remaining in the current throttle window. Only meaningful while
    /// `isOverheated` is `true`.
    private var throttleRemaining: Double = 0
    /// Time accrued toward the next net-worth history sample.
    private var sampleAccumulator: Double = 0
    private let sampleInterval: Double = 10   // seconds between samples
    private let maxSamples = 50

    // MARK: - Init

    /// Creates an engine bound to `gameState`, starting on `stage`.
    init(gameState: GameState, stage: StageDefinition) {
        self.gameState = gameState
        self.currentStage = stage
    }

    // MARK: - Derived rates

    /// Total compute produced per second by ALL owned gear across every stage — so GPUs
    /// bought in earlier rooms keep earning after the player advances (design §6).
    var computePerSec: Double {
        gameState.ownedGear.reduce(0.0) { partial, entry in
            guard let gear = Stages.gearByID[entry.key] else { return partial }
            return partial + Double(entry.value) * gear.computePerSecond
        }
    }

    /// Cash earned per second, including the current boost multiplier.
    var cashPerSec: Double {
        computePerSec * currentStage.computeToCashRate * boostMultiplier
    }

    /// Seconds in a 30-day month; the entered monthly income is spread across this.
    private let secondsPerMonth: Double = 30 * 24 * 3600

    /// The player's salary trickling in per second — their only passive income
    /// beyond gear (design §6). Not affected by the overclock boost.
    var incomePerSec: Double {
        gameState.monthlyIncome / secondsPerMonth
    }

    // MARK: - Frame update

    /// Advances the simulation by `dt` seconds. Call once per frame.
    ///
    /// Handles cooling/heating of the boost, the overheat throttle countdown,
    /// and passive cash accrual using the multiplier resolved this frame.
    func update(dt: TimeInterval) {
        guard dt > 0 else { return }

        if isOverheated {
            // Serving the throttle penalty: pinned to the reduced multiplier.
            throttleRemaining -= dt
            boostMultiplier = throttleMultiplier
            if throttleRemaining <= 0 {
                isOverheated = false
                throttleRemaining = 0
                heat = 0
                boostMultiplier = 1.0
            }
        } else {
            // Cool down, then derive boost from the remaining heat.
            heat = max(0, heat - coolRate * dt)
            boostMultiplier = 1 + (heat / 100) * (maxBoost - 1)
        }

        // Gear income lands as cash. Salary splits by the budget: the invested share
        // goes into the compounding pot, the rest is spendable cash.
        let salary = incomePerSec * dt
        let alloc = min(max(gameState.investAllocation, 0), 1)
        let invested = salary * alloc
        gameState.cash += cashPerSec * dt + (salary - invested)
        // Grow the existing balance first, then add this tick's fresh contribution — so new
        // money doesn't earn a full period of return the instant it lands.
        gameState.investedBalance += gameState.investedBalance * annualReturn * (dt / secondsPerYear)
        gameState.investedBalance += invested

        // Periodically snapshot net worth for the shareable progress curve.
        sampleAccumulator += dt
        if sampleAccumulator >= sampleInterval {
            sampleAccumulator = 0
            gameState.netWorthHistory.append(gameState.netWorth)
            if gameState.netWorthHistory.count > maxSamples {
                gameState.netWorthHistory.removeFirst(gameState.netWorthHistory.count - maxSamples)
            }
        }
    }

    // MARK: - Interaction

    /// Registers a tap on the rig, adding heat (and thus boost). No-op while
    /// overheated or while the player owns no gear. Pushing heat to 100 trips
    /// an overheat.
    func registerTap() {
        guard !isOverheated, gameState.ownsAnyGear else { return }

        heat = min(100, heat + tapHeat)
        if heat >= 100 {
            triggerOverheat()
        }
    }

    /// Enters the overheat throttle state.
    private func triggerOverheat() {
        isOverheated = true
        throttleRemaining = throttleSeconds
        boostMultiplier = throttleMultiplier
    }

    // MARK: - Purchasing

    /// Whether the player can currently afford `gear`.
    func canAfford(_ gear: GearDefinition) -> Bool {
        gameState.cash >= Double(gear.cost)
    }

    /// Attempts to buy one unit of `gear`. Deducts the cost and increments the
    /// owned count on success.
    /// - Returns: `true` if purchased, `false` if unaffordable.
    @discardableResult
    func purchase(_ gear: GearDefinition) -> Bool {
        guard canAfford(gear) else { return false }
        gameState.cash -= Double(gear.cost)
        gameState.ownedGear[gear.id, default: 0] += 1
        return true
    }

    // MARK: - Offline earnings

    /// Credits idle earnings for time elapsed since `gameState.lastSeen`,
    /// capped at `offlineCapSeconds`. Uses the base (un-boosted) rate, then
    /// advances `lastSeen` to `now`.
    /// - Returns: The amount of cash credited.
    @discardableResult
    func applyOfflineEarnings(now: Date) -> Double {
        let elapsed = now.timeIntervalSince(gameState.lastSeen)
        let clampedElapsed = min(max(0, elapsed), offlineCapSeconds)
        let idlePerSec = computePerSec * currentStage.computeToCashRate
        let salaryTotal = incomePerSec * clampedElapsed
        let alloc = min(max(gameState.investAllocation, 0), 1)
        let invested = salaryTotal * alloc
        let credited = idlePerSec * clampedElapsed + (salaryTotal - invested)
        gameState.cash += credited
        gameState.investedBalance += gameState.investedBalance * annualReturn * (clampedElapsed / secondsPerYear)
        gameState.investedBalance += invested
        gameState.lastSeen = now
        // Drop a history point on return so the share curve reflects offline progress too.
        gameState.netWorthHistory.append(gameState.netWorth)
        if gameState.netWorthHistory.count > maxSamples {
            gameState.netWorthHistory.removeFirst(gameState.netWorthHistory.count - maxSamples)
        }
        return credited
    }
}
