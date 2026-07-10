//
//  Sound.swift
//  FinLingo
//
//  A free, built-in UI click for every button — no bundled audio, no licensing, no cost.
//  If a licensed click is ever purchased, drop the .wav in the bundle and swap the body of
//  `Sound.tap()` to play it via AVAudioPlayer; nothing else changes.
//

import SwiftUI
import AudioToolbox

enum Sound {
    /// A short system "tock" — Apple's built-in UI click.
    static func tap() {
        AudioServicesPlaySystemSound(1104)
    }
}

/// Plays a click on press and adds a subtle press animation. Renders the label plainly so
/// buttons keep whatever background/shape they already carry.
struct ClickStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Sound.tap() }
            }
    }
}

extension ButtonStyle where Self == ClickStyle {
    static var clicky: ClickStyle { ClickStyle() }
}
