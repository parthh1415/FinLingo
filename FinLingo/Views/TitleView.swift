//
//  TitleView.swift
//  FinLingo
//
//  The very first screen: a branded title with the pixel mascot and a START button, shown
//  once before a new player sets up their profile.
//

import SwiftUI

struct TitleView: View {
    var onStart: () -> Void

    @State private var bob = false

    private let bg = Color(red: 0.043, green: 0.055, blue: 0.07)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()

                // The mascot is the player sprite, gently bobbing.
                Image(uiImage: PixelArtStyle.pixelArtImage(named: "player_down_idle", size: CGSize(width: 18, height: 26)))
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 84, height: 122)
                    .offset(y: bob ? -6 : 0)
                    .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: bob)
                    .shadow(color: .black.opacity(0.5), radius: 8, y: 4)

                VStack(spacing: 10) {
                    Text("💸 FinLingo")
                        .font(.system(size: 40, weight: .heavy, design: .monospaced))
                        .foregroundColor(cream)
                    Text("build your money confidence")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(term)
                }

                Spacer()

                Button { Sound.tap(); onStart() } label: {
                    Text("START")
                        .font(.system(.headline, design: .monospaced).weight(.bold))
                        .foregroundColor(Color(red: 0.06, green: 0.08, blue: 0.09))
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(amber)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.clicky)
                .padding(.horizontal, 40)

                Text("a financial-literacy simulator")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(cream.opacity(0.4))
                    .padding(.bottom, 26)
            }
            .padding(.horizontal, 24)
        }
        .font(.system(.body, design: .monospaced))
        .onAppear { bob = true }
    }
}
