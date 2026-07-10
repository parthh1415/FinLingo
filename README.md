# FinLingo

**A cozy pixel-art money-life game that teaches real financial literacy by letting you live it.**

FinLingo wraps genuine money skills — budgeting, investing, credit, saving, negotiating — inside a warm, top-down idle game. You enter your real situation, learn money concepts, practice them against **real market data**, grow your income and net worth, and watch your future take shape.

Built for early-career women building their first money confidence — connecting money to career growth, independence, and community — in a format that feels approachable and empowering rather than intimidating.

---

## The core loop

```
Enter your real profile (name, age, job, income, savings, debt, goals)
        ↓
Your monthly income idles in passively — even while away
        ↓
LEARN money skills (left computer)  ⇄  PRACTICE them hands-on (right computer)
        ↓
Earn cash → grow your income (career) → invest it (budget) → net worth climbs
        ↓
See your Future You, decorate your space, share your progress
```

Everything is computed from **your** numbers — every projection, calculator, and lesson is personalized to you.

---

## Features

### 🏠 Your apartment
A softly-lit, top-down **pixel-art room** with a character you move around. It has the full idle-game backbone: passive income, offline "welcome back" earnings, a tap-to-boost overclock, an upgrades shop, and bigger spaces to grow into.

### 📝 Onboarding — a real profile, not a name field
You enter **name, age, job title, monthly income, spending, current savings/investments, debt, goals, and household**. This drives *every* calculation in the app — net worth, projections, the calculators, and the Career screen all reflect your actual situation.

### 📈 Live HUD
- **Cash** (ticks up in real time) and **Income** (tap → Career)
- **Earning/hr** (tap → Budget) and a **Shop** for upgrades
- A **mute toggle** for the ambient music

### 💸 Idle economy
- Your **entered monthly income** is the sole passive income, accruing per second and offline (capped, with a "welcome back" summary).
- **Net worth = cash + investments − debt.** The invested share compounds at 7%.

### 📖 Lessons (left computer)
Six bite-size lessons — **50/30/20 budgeting, emergency funds, compound interest, using credit, high-yield savings, and salary negotiation** — each teaching a concept then checking it, with a one-time cash reward. Lessons **reorder to match your goals**, and several link to the matching hands-on Simulator tool.

### 🧪 Simulator (right computer) — a hub of hands-on tools
- **🔮 Future You** — an animated net-worth projection to age 65 from *your* real numbers, with milestone flags ("$1M by 44") and a dashed "if you invested more" comparison line.
- **📊 Trading sandbox** — practice investing with **real historical prices (AAPL, NVDA)**. Press play and buy/sell as the days auto-advance; profits get invested and compound into your net worth.
- **🏦 401(k) calculator** — projected nest egg split into your money, the employer match, and compounding growth.
- **💹 Invest $X/month** — watch small monthly amounts snowball.
- **💳 Debt payoff** — real amortization: months to clear and total interest (pre-filled with your debt).
- **🛟 Emergency fund** — how many months you're covered vs 3–6 month targets.

### 💼 Career
Shows **your real job title and salary**. Win a one-time salary negotiation and take on side hustles that permanently grow your monthly income — money tied to career growth.

### 🧮 Budget board
Pick a needs/wants/save/invest strategy; the invested slice compounds into your net worth. Includes **anonymized peer social proof** ("Peers earning ~$3–4k/mo chose the 50/30/20 split 55% of the time") for your income band.

### 🌐 Community (no backend needed)
- Income-banded **peer stats** on the Budget board so you're not alone.
- A **shareable net-worth card** — your progress curve rendered to an image and posted via the iOS share sheet.

### 🔊 Audio
- An **original, synthesized click** on every button (soft & rounded).
- An **original ambient pad loop** — a calm, beatless background track (self-made, so zero licensing).

---

## Tech stack

- **Swift · SwiftUI · SpriteKit** (iOS, built in Xcode)
- **SpriteKit** for the top-down pixel-art room; **SwiftUI** for all panels, in a cohesive retro-terminal style
- **AVFoundation / AudioToolbox** for the ambient loop and click SFX
- **Codable → JSON** local-first persistence (NaN-safe)
- **Real market data** from the Alpha Vantage API, baked into the trading scenarios

No backend, no accounts, no external assets — everything runs locally.

---

## Running it

1. Open `FinLingo.xcodeproj` in Xcode (16+/26).
2. Select the **FinLingo** scheme and an iOS simulator (e.g. iPhone 17) or a device.
3. Run (⌘R).

The app is local-first; no API key is required to play (market data is bundled into the trading scenarios).

---

## Project structure

```
FinLingo/
  Models/        GameState (Codable), Stage/Gear definitions
  Engine/        EconomyEngine, StageController, PersistenceController
  Scenes/Nodes/  SpriteKit room, player, interactive furniture
  Views/         Onboarding, Lessons, Simulator (+ tools), Career, Budget,
                 Community, Future You, HUD, Marketplace, WelcomeBack
  Support/       Sound (click SFX), Music (ambient loop), Theme, Color+Hex
  Utilities/     Formatting, pixel-art rendering, layout
  Data/          Stage/gear catalogs
  ambient.wav    original ambient loop
  click.wav      original UI click
```

---

## Roadmap

- **Reinvent Lessons into a game** — a roguelike "Money Run" (draw life events, play money-move cards) plus a daily shareable money puzzle, so learning is a game you return to daily.
- **More trading tickers & live data refresh.**
- **Real community backend** (accounts, sharing, leagues) as a defined later phase.
- **Apartment glow-up** re-themed to living-space progression with earned décor.

---

*FinLingo is a work in progress. Every commit is playable.*
