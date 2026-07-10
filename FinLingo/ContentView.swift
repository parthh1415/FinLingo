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
        Group {
            if onboarded {
                GameView()
            } else {
                OnboardingView { onboarded = true }
            }
        }
        .buttonStyle(.clicky) // every button clicks by default
    }
}
