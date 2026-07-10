//
//  LifeEvent.swift
//  FinLingo
//
//  Life events that interrupt the money-life timeline. Each is a real financial decision;
//  every choice bends the curve (cash / debt / income / investments) and teaches a lesson.
//

import Foundation

struct LifeEvent: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let detail: String
    let choices: [Choice]

    struct Choice: Identifiable {
        let id = UUID()
        let label: String
        let outcome: String           // what the player sees after choosing
        var cash: Double = 0          // delta to spendable cash (overflow below 0 becomes debt)
        var debt: Double = 0          // delta to debt
        var income: Double = 0        // delta to monthly income (raises, hustles)
        var invested: Double = 0      // delta to invested balance
    }
}

enum LifeEventCatalog {
    // Fires roughly twice a year; each event is used at most once per run.
    static let all: [LifeEvent] = [
        LifeEvent(id: "car", emoji: "🚗", title: "Your car breaks down",
                  detail: "The repair is $800. How do you cover it?",
                  choices: [
                    .init(label: "Pay from savings", outcome: "Boring, but no interest and no stress. This is exactly what an emergency fund is for.", cash: -800),
                    .init(label: "Put it on the credit card", outcome: "Easy now — but at ~22% APR it'll cost you more the longer it sits.", debt: 950),
                    .init(label: "Skip repairs, keep driving", outcome: "It got worse. The eventual fix cost more.", cash: -1200),
                  ]),
        LifeEvent(id: "raise", emoji: "💼", title: "Review season",
                  detail: "Your manager opens with a 2% bump. What do you do?",
                  choices: [
                    .init(label: "Counter with market research", outcome: "You landed a real raise. First salaries compound for a whole career.", income: 450),
                    .init(label: "Just take the 2%", outcome: "Safe, but you left money on the table.", income: 90),
                  ]),
        LifeEvent(id: "bonus", emoji: "🎁", title: "Surprise bonus!",
                  detail: "$1,500 lands in your account. What now?",
                  choices: [
                    .init(label: "Invest all of it", outcome: "Future-you says thanks — that's decades of compounding.", invested: 1500),
                    .init(label: "Split it 50/50", outcome: "A little joy, a little growth. Balanced.", cash: 750, invested: 750),
                    .init(label: "Treat yourself", outcome: "Fun! But it's gone — nothing compounds.", cash: 1500),
                  ]),
        LifeEvent(id: "phone", emoji: "📱", title: "Your phone dies",
                  detail: "Time for a new one. Which do you get?",
                  choices: [
                    .init(label: "The $1,200 flagship", outcome: "Shiny — but a big want dressed up as a need.", cash: -1200),
                    .init(label: "A solid $300 model", outcome: "Does everything you need. Smart.", cash: -300),
                  ]),
        LifeEvent(id: "crypto", emoji: "🪙", title: "A 'can't-miss' crypto tip",
                  detail: "A friend swears this coin will 10×. They want you all in for $1,000.",
                  choices: [
                    .init(label: "Go all in", outcome: "It tanked 60%. Hype is not a strategy.", cash: -600),
                    .init(label: "Pass, keep investing steadily", outcome: "Boring beats broke. Steady index investing wins over time.", invested: 100),
                  ]),
        LifeEvent(id: "medical", emoji: "🩺", title: "Surprise medical bill",
                  detail: "$2,000, due now.",
                  choices: [
                    .init(label: "Pay from your fund", outcome: "This is why the cushion exists.", cash: -2000),
                    .init(label: "Payment plan", outcome: "Manageable monthly — but it adds to what you owe.", debt: 2200),
                  ]),
        LifeEvent(id: "wedding", emoji: "💍", title: "Destination wedding invite",
                  detail: "Flights + hotel would run about $1,500.",
                  choices: [
                    .init(label: "Go all out", outcome: "Memories! But a big hit to the budget.", cash: -1500),
                    .init(label: "Send a thoughtful gift", outcome: "You showed up for them without wrecking your month.", cash: -150),
                  ]),
        LifeEvent(id: "match", emoji: "🏦", title: "New 401(k) match",
                  detail: "Your employer will now match retirement contributions. Enroll?",
                  choices: [
                    .init(label: "Enroll and grab the match", outcome: "Free money — the best return you'll ever get.", invested: 1200),
                    .init(label: "Skip it for now", outcome: "You left the free match on the table.", cash: 0),
                  ]),
    ]
}
