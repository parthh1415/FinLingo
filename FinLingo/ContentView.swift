//
//  ContentView.swift
//  FinLingo
//
//  Root gate: first-run players see onboarding; returning players go straight to the game.
//

import SwiftUI

struct ContentView: View {
    @State private var onboarded = PersistenceController.load()?.hasOnboarded ?? false

    var body: some View {
        if onboarded {
            GameView()
        } else {
            OnboardingView { onboarded = true }
        }
    }
}
