//
//  OnboardingView.swift
//  FinLingo
//
//  First-run profile setup. The player enters the one number that drives the whole
//  economy — their monthly income — plus goals, spending, and household, which tailor
//  the lessons. Styled like the in-game computer screens so it feels of a piece.
//

import SwiftUI

struct OnboardingView: View {
    /// Called once the profile is saved, so the root can switch to the game.
    var onComplete: () -> Void

    @State private var nameText = ""
    @State private var ageText = ""
    @State private var jobText = ""
    @State private var incomeText = ""
    @State private var spendingText = ""
    @State private var savingsText = ""
    @State private var debtText = ""
    @State private var goals: [String] = []
    @State private var household = "just_me"

    private static let goalOptions: [(id: String, label: String)] = [
        ("emergency_fund", "Emergency fund"),
        ("pay_off_debt", "Pay off debt"),
        ("buy_home", "Buy a home"),
        ("start_investing", "Start investing"),
        ("travel", "Save to travel"),
        ("retirement", "Retirement"),
    ]
    private static let householdOptions: [(id: String, label: String)] = [
        ("just_me", "Just me"),
        ("partner", "Me + partner"),
        ("kids", "I have kids"),
        ("supporting_family", "Supporting family"),
    ]

    private let screen = Color(red: 0.055, green: 0.075, blue: 0.09)
    private let edge = Color(red: 0.83, green: 0.66, blue: 0.33)
    private let cream = Color(red: 0.96, green: 0.90, blue: 0.70)
    private let amber = Color(red: 0.93, green: 0.70, blue: 0.32)
    private let term = Color(red: 0.55, green: 0.80, blue: 0.52)
    private var dim: Color { cream.opacity(0.45) }

    private var income: Double? {
        guard let value = Double(incomeText), value > 0 else { return nil }
        return value
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                titleBar
                Rectangle().fill(edge.opacity(0.35)).frame(height: 1)
                form
                Rectangle().fill(edge.opacity(0.35)).frame(height: 1)
                startButton
            }
            .background(screen)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(edge.opacity(0.75), lineWidth: 2))
            .padding(.horizontal, 18)
            .padding(.vertical, 40)
        }
        .font(.system(.body, design: .monospaced))
    }

    private var titleBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 5) {
                Circle().fill(Color(red: 0.86, green: 0.28, blue: 0.24)).frame(width: 9, height: 9)
                Circle().fill(amber).frame(width: 9, height: 9)
                Circle().fill(term).frame(width: 9, height: 9)
            }
            Text("welcome.finlingo").font(.system(.footnote, design: .monospaced)).foregroundColor(dim)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Let's set up your money life").font(.system(.title3, design: .monospaced).weight(.bold)).foregroundColor(cream)
                Text("Your real numbers, so every projection is actually about you. You start the game with $1,000 to play with.")
                    .font(.system(.caption, design: .monospaced)).foregroundColor(dim).lineSpacing(2)

                field(label: "First name", text: $nameText, placeholder: "e.g. Maya", keyboard: .default)
                HStack(alignment: .top, spacing: 10) {
                    field(label: "Age", text: $ageText, placeholder: "e.g. 24")
                    field(label: "Job title", text: $jobText, placeholder: "e.g. Analyst", keyboard: .default)
                }
                field(label: "Monthly income", text: $incomeText, placeholder: "e.g. 3000")
                field(label: "Typical monthly spending (optional)", text: $spendingText, placeholder: "e.g. 1800")
                HStack(alignment: .top, spacing: 10) {
                    field(label: "Saved / invested", text: $savingsText, placeholder: "e.g. 2000")
                    field(label: "Debt owed", text: $debtText, placeholder: "e.g. 1500")
                }

                Text("> what are you working toward?").font(.system(.caption, design: .monospaced)).foregroundColor(term)
                chips(Self.goalOptions, isOn: { goals.contains($0) }, tap: toggleGoal)

                Text("> who are you budgeting for?").font(.system(.caption, design: .monospaced)).foregroundColor(term)
                chips(Self.householdOptions, isOn: { household == $0 }, tap: { household = $0 })
            }
            .padding(16)
        }
        .frame(maxHeight: 520)
    }

    private func field(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .numberPad) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(.caption, design: .monospaced).weight(.bold)).foregroundColor(cream)
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(dim))
                .keyboardType(keyboard)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(cream)
                .padding(12)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(edge.opacity(0.4), lineWidth: 1))
        }
    }

    private func chips(_ options: [(id: String, label: String)], isOn: @escaping (String) -> Bool, tap: @escaping (String) -> Void) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(options, id: \.id) { option in
                Button { tap(option.id) } label: {
                    Text(option.label)
                        .font(.system(.caption, design: .monospaced))
                        .padding(.horizontal, 12).padding(.vertical, 9)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(isOn(option.id) ? Color(red: 0.06, green: 0.08, blue: 0.09) : cream)
                        .background(isOn(option.id) ? amber : Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 999, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 999, style: .continuous).stroke(edge.opacity(isOn(option.id) ? 0 : 0.4), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var startButton: some View {
        Button { submit() } label: {
            Text("MOVE IN")
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(income == nil ? dim : Color(red: 0.06, green: 0.08, blue: 0.09))
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(income == nil ? Color.white.opacity(0.06) : amber)
        }
        .disabled(income == nil)
    }

    private func toggleGoal(_ id: String) {
        if let index = goals.firstIndex(of: id) { goals.remove(at: index) } else { goals.append(id) }
    }

    private func submit() {
        guard let income else { return }
        // Cap the free-text numbers so downstream Int() conversions can never overflow/crash.
        let cap = 100_000_000.0
        let spending = min(max(Double(spendingText) ?? 0, 0), cap)
        let savings = min(max(Double(savingsText) ?? 0, 0), cap)
        let debt = min(max(Double(debtText) ?? 0, 0), cap)
        let age = min(max(Int(ageText) ?? 25, 16), 100)
        let state = GameState(
            cash: 1000,
            lastSeen: Date(),
            hasOnboarded: true,
            monthlyIncome: min(income, cap),
            monthlySpending: spending,
            goals: goals,
            household: household,
            // Their existing savings/investments become the starting invested balance so it
            // compounds and shows up in net worth and Future You.
            investedBalance: savings,
            playerName: nameText.trimmingCharacters(in: .whitespaces),
            age: age,
            jobTitle: jobText.trimmingCharacters(in: .whitespaces),
            debt: debt
        )
        PersistenceController.save(state)
        onComplete()
    }
}
