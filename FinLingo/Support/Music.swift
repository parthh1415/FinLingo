//
//  Music.swift
//  FinLingo
//
//  Looping ambient background music — an original, self-generated warm pad (see
//  ambient.wav), so there are no licensing costs. Uses the .ambient audio session so it
//  mixes politely with other audio and respects the silent switch. A mute toggle persists.
//

import SwiftUI
import Combine
import AVFoundation

final class MusicManager: ObservableObject {
    static let shared = MusicManager()

    @Published private(set) var isOn: Bool
    private var player: AVAudioPlayer?

    private init() {
        isOn = UserDefaults.standard.object(forKey: "musicOn") as? Bool ?? true
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        if let url = Bundle.main.url(forResource: "ambient", withExtension: "wav") {
            player = try? AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1   // seamless loop forever
            player?.volume = 0.32        // soft, background level
            player?.prepareToPlay()
        }
    }

    /// Begin playback if the player hasn't muted it. Safe to call repeatedly.
    func startIfEnabled() {
        if isOn, let p = player, !p.isPlaying { p.play() }
    }

    func toggle() {
        isOn.toggle()
        UserDefaults.standard.set(isOn, forKey: "musicOn")
        if isOn { player?.play() } else { player?.pause() }
    }
}

/// Small speaker button to mute/unmute the ambient loop.
struct MusicToggle: View {
    @ObservedObject private var music = MusicManager.shared

    var body: some View {
        Button { music.toggle() } label: {
            Image(systemName: music.isOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.55))
                .frame(width: 30, height: 30)
                .background(Color.black.opacity(0.25))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
