import Combine
import SpriteKit
import SwiftUI

/// UI bridge so the SpriteKit scene can drive SwiftUI overlays.
final class GameUIState: ObservableObject {
    @Published var showLessons = false
    @Published var showSimulator = false
    @Published var showCareer = false
    @Published var showBudget = false
    @Published var showMarketplace = false
    @Published var welcomeBackAmount: Double = 0
    /// When a lesson's "Practice this" link opens the Simulator, which tool to jump straight to.
    @Published var pendingSimTool: SimTool?

    /// Close any open panel — used before showing the welcome-back popup so modals never stack.
    func closePanels() {
        showLessons = false
        showSimulator = false
        showCareer = false
        showBudget = false
        showMarketplace = false
    }
}

struct GameView: View {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var gameState: GameState
    @StateObject private var economy: EconomyEngine
    @StateObject private var stageController: StageController
    @StateObject private var ui: GameUIState
    @StateObject private var sim: SimulationEngine
    @State private var scene: WorldScene

    // HUD band proportions — from the GameView scaffold.
    private let topHUDHeightFraction: CGFloat = 0.12
    private let bottomHUDHeightFraction: CGFloat = 0.10

    init() {
        let gs = PersistenceController.load() ?? GameState()
        let stages = Stages.all
        let startStage = stages[max(0, min(gs.currentStageIndex, stages.count - 1))]
        let engine = EconomyEngine(gameState: gs, stage: startStage)
        let controller = StageController(stages: stages, gameState: gs)
        let uiState = GameUIState()
        let world = WorldScene(gameState: gs, economy: engine, stageController: controller)
        world.onOpenLessons = { [uiState] in Sound.tap(); uiState.closePanels(); uiState.showLessons = true }
        world.onOpenSimulator = { [uiState] in Sound.tap(); uiState.closePanels(); uiState.pendingSimTool = nil; uiState.showSimulator = true }

        _gameState = StateObject(wrappedValue: gs)
        _economy = StateObject(wrappedValue: engine)
        _stageController = StateObject(wrappedValue: controller)
        _ui = StateObject(wrappedValue: uiState)
        _sim = StateObject(wrappedValue: SimulationEngine(gameState: gs))
        _scene = State(initialValue: world)
    }

    private let simBarHeight: CGFloat = 54

    /// True whenever a full-screen panel or popup is hiding the game — the life sim holds
    /// still so months don't tick (and events don't fire) behind the player's back.
    private var gameCovered: Bool {
        ui.showLessons || ui.showSimulator || ui.showCareer
            || ui.showBudget || ui.showMarketplace || ui.welcomeBackAmount >= 1
            || sim.pendingEvent != nil                                  // a life-scenario decision freezes the room
            || (gameState.hasOnboarded && !gameState.hasSeenTutorial)   // the coach tour freezes the world too
    }

    var body: some View {
        ZStack {
            Color(PixelArtStyle.Palette.darkOutside).ignoresSafeArea()

            // Portrait layout on the structure: top HUD band | game area | bottom HUD band.
            GeometryReader { geo in
                let topH = geo.size.height * topHUDHeightFraction
                let bottomH = geo.size.height * bottomHUDHeightFraction
                let gameH = max(0, geo.size.height - topH - bottomH - simBarHeight)

                VStack(spacing: 0) {
                    TopHUDView(gameState: gameState, ui: ui)
                        .frame(width: geo.size.width, height: topH)

                    SimBar(sim: sim, gameState: gameState)
                        .padding(.horizontal, 12)
                        .frame(width: geo.size.width, height: simBarHeight)

                    ZStack {
                        Color(PixelArtStyle.Palette.darkOutside)
                        SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                            .frame(width: geo.size.width, height: gameH)
                            .clipped()
                        VStack {
                            Spacer()
                            OverclockButton(economy: economy, gameState: gameState)
                                .padding(.bottom, 8)
                        }
                    }
                    .frame(width: geo.size.width, height: gameH)
                    .overlay(alignment: .topTrailing) {
                        MusicToggle().padding(10)
                    }

                    BottomHUDView(gameState: gameState, economy: economy, ui: ui)
                        .frame(width: geo.size.width, height: bottomH)
                }
            }
            // NOTE: the content deliberately respects the safe area so the top HUD sits below the
            // camera/Dynamic Island and the bottom HUD clears the home indicator; only the dark
            // background above bleeds edge-to-edge.

            // Overlays
            if ui.showLessons {
                LessonsView(gameState: gameState, onPractice: { tool in
                    // Hop straight from a lesson to the matching hands-on Simulator tool.
                    ui.pendingSimTool = tool
                    ui.showLessons = false
                    ui.showSimulator = true
                }) { ui.showLessons = false }
            }
            if ui.showSimulator {
                SimulatorView(gameState: gameState, initialTool: ui.pendingSimTool) { ui.showSimulator = false }
            }
            if ui.showCareer {
                CareerView(gameState: gameState) { ui.showCareer = false }
            }
            if ui.showBudget {
                BudgetView(gameState: gameState) { ui.showBudget = false }
            }
            if ui.showMarketplace {
                MarketplaceView(gameState: gameState, economy: economy) { ui.showMarketplace = false }
            }
            if ui.welcomeBackAmount >= 1 {
                WelcomeBackView(amount: ui.welcomeBackAmount) { ui.welcomeBackAmount = 0 }
            }
            if let event = sim.pendingEvent {
                LifeEventView(event: event) { sim.resolve($0) }
            }

            // One-time coach tour for brand-new players — sits on top of everything, and hands
            // straight off to the first real-life scenario when it finishes.
            if gameState.hasOnboarded && !gameState.hasSeenTutorial {
                TutorialOverlay(playerName: gameState.playerName) {
                    gameState.hasSeenTutorial = true
                    PersistenceController.save(gameState)
                    sim.beginFirstScenario()
                }
            }
        }
        .onAppear { creditOfflineEarnings(); sim.start() }
        // `initial: true` so the very first render (e.g. the coach tour, which starts covered)
        // freezes the world too — onChange alone skips the initial value.
        .onChange(of: gameCovered, initial: true) { _, covered in
            sim.isSuspended = covered
            scene.isPaused = covered   // freeze movement/economy too, so she can't wander behind a panel
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                creditOfflineEarnings()
            case .background:
                gameState.lastSeen = Date()
                PersistenceController.save(gameState)
            default:
                break
            }
        }
    }

    private func creditOfflineEarnings() {
        let credited = economy.applyOfflineEarnings(now: Date())
        if credited >= 1 {
            ui.closePanels() // don't let the welcome-back popup stack on top of an open panel
            ui.welcomeBackAmount = credited
        }
    }
}

// MARK: - HUD bands

private let hudFill = Color(red: 0.08, green: 0.11, blue: 0.15)
private let hudDivider = Color(red: 0.25, green: 0.34, blue: 0.43)
private let hudLabel = Color(red: 0.70, green: 0.78, blue: 0.86)
private let hudAmber = Color(red: 0.93, green: 0.70, blue: 0.32)
private let hudTerm = Color(red: 0.55, green: 0.80, blue: 0.52)

/// Top band: your wallet and the salary flowing into it. Tapping income opens Career.
private struct TopHUDView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var ui: GameUIState

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("NET WORTH").font(.system(size: 11, weight: .semibold, design: .monospaced)).foregroundStyle(hudLabel)
                Text(CurrencyFormat.signed(gameState.netWorth))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white).monospacedDigit()
                Text("cash \(CurrencyFormat.short(gameState.cash))")
                    .font(.system(size: 10, design: .monospaced)).foregroundStyle(hudLabel.opacity(0.8))
            }
            Spacer()
            Button { ui.closePanels(); ui.showCareer = true } label: {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("INCOME ›").font(.system(size: 11, weight: .semibold, design: .monospaced)).foregroundStyle(hudLabel)
                    Text("\(CurrencyFormat.short(gameState.monthlyIncome))/mo")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(hudAmber).monospacedDigit()
                }
            }
            .buttonStyle(.clicky)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hudFill)
        .overlay(alignment: .bottom) { Rectangle().fill(hudDivider).frame(height: 1) }
    }
}

/// Bottom band: what you're earning per hour, and the shop for room upgrades.
private struct BottomHUDView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var economy: EconomyEngine
    @ObservedObject var ui: GameUIState

    private var perHour: Double { (economy.cashPerSec + economy.incomePerSec) * 3600 }

    var body: some View {
        HStack {
            Button { ui.closePanels(); ui.showBudget = true } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text("BUDGET ›").font(.system(size: 11, weight: .semibold, design: .monospaced)).foregroundStyle(hudLabel)
                    Text("+\(CurrencyFormat.short(perHour))/hr")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(hudTerm).monospacedDigit()
                }
            }
            .buttonStyle(.clicky)
            Spacer()
            Button { ui.closePanels(); ui.showMarketplace = true } label: {
                Text("SHOP")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.06, green: 0.08, blue: 0.09))
                    .padding(.horizontal, 18).padding(.vertical, 9)
                    .background(hudAmber)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hudFill)
        .overlay(alignment: .top) { Rectangle().fill(hudDivider).frame(height: 1) }
    }
}
