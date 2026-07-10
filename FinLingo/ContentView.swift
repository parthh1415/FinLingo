//
//  ContentView.swift
//  FinLingo
//
//  Root gate: first-run players see onboarding; returning players go straight to the game.
//

import SwiftUI

struct ContentView: View {
    @State private var onboarded = PersistenceController.load()?.hasOnboarded ?? false
    @State private var started = false

    var body: some View {
        Group {
            if onboarded {
                GameView()                                   // returning players go straight in
            } else if !started {
                TitleView { started = true }                 // new players: title first…
            } else {
                OnboardingView { onboarded = true }          // …then the profile setup
            }
        }
        .buttonStyle(.clicky) // every button clicks by default
        .onAppear { MusicManager.shared.startIfEnabled() }
    }
}
