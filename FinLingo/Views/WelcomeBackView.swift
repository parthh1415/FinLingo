import SwiftUI

struct WelcomeBackView: View {
    let amount: Double            // cash earned while away
    var onClose: () -> Void

    private let cardColor = Color(red: 0.32, green: 0.22, blue: 0.17)
    private let creamColor = Color(red: 0.95, green: 0.89, blue: 0.77)
    private let amberColor = Color(red: 0.83, green: 0.66, blue: 0.33)

    var body: some View {
        ZStack {
            // Dimmed scrim: tapping dismisses.
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onClose() }

            // Centered card.
            VStack(spacing: 16) {
                Text("Welcome back!")
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(creamColor)

                Text("While you were away your money earned")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(creamColor.opacity(0.85))
                    .multilineTextAlignment(.center)

                Text(CurrencyFormat.short(amount))
                    .font(.system(.largeTitle, design: .monospaced))
                    .fontWeight(.heavy)
                    .foregroundColor(amberColor)

                Button(action: { onClose() }) {
                    Text("Collect")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(cardColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(amberColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: 300)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(amberColor.opacity(0.6), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.5), radius: 12, y: 6)
            // Absorb taps so tapping the card does not dismiss.
            .contentShape(Rectangle())
            .onTapGesture { }
            .transition(.scale.combined(with: .opacity))
        }
        .font(.system(.body, design: .monospaced))
    }
}

#Preview {
    WelcomeBackView(amount: 1234) { }
}
