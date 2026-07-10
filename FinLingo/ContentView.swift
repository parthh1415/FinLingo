//
//  ContentView.swift
//  FinLingo
//
//  Root gate: first-run players see onboarding; returning players go straight to the game.
//

import SwiftUI

struct ContentView: View {
    /// The title acts as a home screen shown every launch: LOAD GAME continues an existing save,
    /// START NEW LIFE wipes it and runs onboarding.
    @State private var route: Route = .title
    @State private var hasSave: Bool = PersistenceController.load()?.hasOnboarded ?? false

    private enum Route { case title, onboarding, game }

    var body: some View {
        Group {
            switch route {
            case .title:
                TitleView(
                    hasSave: $hasSave,
                    onNewLife: {
                        PersistenceController.clear()
                        hasSave = false
                        route = .onboarding
                    },
                    onLoad: { route = .game }
                )
            case .onboarding:
                OnboardingView { hasSave = true; route = .game }
            case .game:
                GameView()
            }
        }
        .buttonStyle(.clicky) // every button clicks by default
        .onAppear { MusicManager.shared.startIfEnabled() }
    }
}
