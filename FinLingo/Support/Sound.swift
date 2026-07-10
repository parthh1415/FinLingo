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
    /// Our original, synthesized click (`click.wav`) registered as a system sound once —
    /// low-latency and overlap-friendly for rapid taps. Falls back to Apple's tock if missing.
    private static let clickID: SystemSoundID = {
        var id: SystemSoundID = 1104
        if let url = Bundle.main.url(forResource: "click", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(url as CFURL, &id)
        }
        return id
    }()

    static func tap() {
        AudioServicesPlaySystemSound(clickID)
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
