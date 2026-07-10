//
//  InventoryView.swift
//  FinLingo
//
//  A terminal-styled modal that lists the GPUs the player currently owns (design §8).
//

import SwiftUI

/// A dark card modal that shows every owned gear stack and its compute contribution.
struct InventoryView: View {

    @ObservedObject var gameState: GameState

    /// Invoked when the player taps Close or the dimmed scrim.
    var onClose: () -> Void

    // MARK: - Palette
    private let scrim = Color.black.opacity(0.6)
    private let card = Color(red: 0.10, green: 0.09, blue: 0.12)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let green = Color(red: 0.55, green: 0.80, blue: 0.52)
    private var dim: Color { cream.opacity(0.45) }

    // MARK: - Rows

    /// A resolved, display-ready owned gear line.
    private struct Row: Identifiable {
        let id: String
        let displayName: String
        let count: Int
        let computePerSecond: Double
    }

    /// Owned gear (count > 0), resolved via the registry and sorted by name.
    private var rows: [Row] {
        gameState.ownedGear
            .compactMap { entry -> Row? in
                let (id, count) = entry
                guard count > 0, let gear = Stages.gearByID[id] else { return nil }
                return Row(
                    id: id,
                    displayName: gear.displayName,
                    count: count,
                    computePerSecond: gear.computePerSecond
                )
            }
            .sorted { $0.displayName < $1.displayName }
    }

    var body: some View {
        ZStack {
            scrim
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onClose() }

            cardBody
                .padding(.horizontal, 20)
        }
        .font(.system(.body, design: .monospaced))
    }

    // MARK: - Card

    private var cardBody: some View {
        VStack(spacing: 0) {
            titleBar
            Rectangle().fill(amber.opacity(0.30)).frame(height: 1)
            content
            Rectangle().fill(amber.opacity(0.30)).frame(height: 1)
            footer
        }
        .background(card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(amber.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 22, y: 10)
        .contentShape(Rectangle())
        .onTapGesture { /* absorb taps inside the card */ }
    }

    private var titleBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "shippingbox.fill")
                .foregroundColor(amber)
            Text("Inventory")
                .font(.system(.title3, design: .monospaced).weight(.bold))
                .foregroundColor(cream)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var content: some View {
        if rows.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(rows) { row in
                        gearRow(row)
                    }
                }
                .padding(16)
            }
            .frame(maxHeight: 400)
        }
    }

    private func gearRow(_ row: Row) -> some View {
        let stackCompute = Double(row.count) * row.computePerSecond
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(row.displayName)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(cream)
                    Text("×\(row.count)")
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundColor(amber)
                        .monospacedDigit()
                }
                Text("+\(NumberFormatShort.short(stackCompute)) c/s")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(green)
                    .monospacedDigit()
            }
            Spacer(minLength: 8)
        }
        .padding(12)
        .background(Color.white.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 30))
                .foregroundColor(dim)
            Text("No gear yet — buy GPUs from the Shop.")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(dim)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 44)
    }

    private var footer: some View {
        Button {
            onClose()
        } label: {
            Text("CLOSE")
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(cream)
                .frame(maxWidth: .infinity, minHeight: 48)
        }
    }
}
