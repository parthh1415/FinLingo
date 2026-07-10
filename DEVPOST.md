## Inspiration

Most young women start their careers having never been taught how money actually works — budgeting, investing, debt, and negotiating a first salary. The tools that exist fall into two camps: financial-literacy apps that feel like dry quizzes, and games that are fun but teach nothing real. We wanted to fuse them into something genuinely addictive. **FinLingo** is a cozy, pixel-art life simulator built for early-career women to _build money confidence_ — where every tap is a real financial decision and your **net worth is the score**. Think Duolingo's bite-sized loop meets an idle life-sim, set in a dorm room where learning literally pays.

## What it does

FinLingo is a native iOS game. You start by creating a profile — name, age, income, monthly spending, existing debt, and goals — and _every calculation in the game is personalized to it_. From your dorm room, two laptops drive the experience:

- **Learn (left laptop).** Bite-sized lessons on budgeting (50/30/20), emergency funds, compound interest, credit, high-yield savings, salary negotiation, and 529 college savings. Each lesson mixes three interactive formats — multiple choice, drag-to-sort, and tap-to-match — and every correct answer pays real in-game cash (once, so it can't be farmed). A **"Practice this"** link jumps straight to the matching hands-on tool.
- **Simulate (right laptop).** A _running, month-by-month life simulation_: net worth sits on the HUD, the clock ticks a month every few seconds, and a live sparkline tracks your trajectory. Each month a real cash-flow model moves your money — income in, an investment allocation that compounds, spending out, and debt that accrues interest. **Life-event scenarios** interrupt with real decisions (your car breaks down, a surprise bonus lands, a medical bill, a 401(k) match) whose choices bend the curve. Hands-on tools include a trading sandbox on _real market history_, 401(k) and 529 projections, a debt-payoff planner, an emergency-fund calculator, and a **"Future You"** projection.

Everything ties back to one number: \\( \text{net worth} = \text{cash} + \text{investments} - \text{debt} \\). Along the way you can adopt a pet cat that follows you around and deck out your dorm, so the reward loop of an idle game reinforces the financial one.

## How we built it

- **Native iOS in Swift** — SwiftUI for the interface, SpriteKit for the explorable dorm world, and Combine to drive the simulation clock.
- **100% code-drawn pixel art.** There are no image assets — the player sprite, the pet cat, the dorm, and the title-screen "Freshman Year" crest are all generated procedurally with Core Graphics and SwiftUI `Canvas`, so everything scales crisply with nearest-neighbor rendering.
- **The simulation engine.** A Combine timer advances one month at a time, applying a cash-flow model: income → investment allocation → spending → carried debt, with any shortfall rolling into debt. Investments compound at a 7% annual return and carried debt at ~18% APR. The invested balance follows the future value of a monthly annuity:

$$ FV = P \cdot \frac{(1 + r)^{n} - 1}{r} $$

where \\( P \\) is the monthly contribution, \\( r \\) the monthly return, and \\( n \\) the number of months. Lessons teach the same intuition — e.g. the Rule of 72, \\( \text{years to double} \approx 72 / \text{rate} \\).

- **Real financial data.** The trading sandbox replays actual market history (e.g. AAPL, NVDA) sourced via Alpha Vantage.
- **Durable state.** Progress persists as Codable JSON with NaN-safe encoding and a corrupt-save quarantine, so a bad file can never silently wipe a player.
- **Synthesized audio** for the UI clicks and a calm ambient loop — no licensed assets.
- **AI-assisted QA.** We ran repeated systematic-debugging sweeps with parallel review agents auditing the money math, persistence, UI, and scene layers.

## Challenges we ran into

- Turning the Simulator from a set of static calculators into a genuine _running_ simulation — net-worth HUD, ticking clock, pause/speed controls, a live curve, and steerable life events — without it feeling like a spreadsheet.
- Drawing rich pixel art entirely in code: every sprite and the title diorama is hand-plotted rectangles, coins, and light cones.
- Data-loss bugs: manual `Codable` conformance silently wiped saves when a field was missing from the encoder/decoder, and unbounded compounding could push a `NaN`/`Inf` into the persisted net-worth history.
- Sequencing a clean first run (title → profile → tutorial → first scenario) and _freezing the world_ behind modals and the coach tour so time wouldn't advance out of sight.
- Financial correctness: money conservation, compounding order, debt amortization, and divide-by-zero guards across every calculator.

## Accomplishments that we're proud of

- A genuinely running, month-by-month life simulation with net worth as the score and life events that change the outcome.
- Every pixel of art is generated in code — zero external image files.
- Real stock-market data powering a risk-free trading sandbox.
- Six-plus lessons across three interactive formats with abuse-proof, once-ever scoring, each linked to a hands-on practice tool.
- A cohesive, presentable first-run flow and a polished, game-style home screen.
- Rigor: parallel-agent debugging verified Codable symmetry, financial math, and crash safety end to end.

## What we learned

- How to integrate SwiftUI and SpriteKit and drive a simulation loop with Combine.
- Real financial modeling — annuity future value, compound interest, the Rule of 72, and debt amortization — translated into code a player can _feel_.
- The sharp edges of hand-written `Codable` conformance and floating-point safety in persisted data.
- Procedural pixel-art techniques for characters, scenes, and UI.
- Designing for a specific audience: clarity, encouragement, and relevance beat jargon every time.

## What's next for FinLingo

- **More levels beyond Freshman Year** — sophomore year, a first job and salary negotiation, moving out, buying a home, and long-term retirement.
- **A room-decoration economy**: spend earned cash on posters, plants, and lights, plus richer pet interactions, so the idle loop deepens.
- **Community**: leaderboards, shareable net-worth cards, and "% of people your age got this right" insights.
- **More content and personalization**: additional life events and lessons, plus AI-generated lesson plans tailored to each player's goals.
- **New modes**: a daily money puzzle and a card-based "Money Run" roguelike for replayable, addictive learning.
- **Backend and cloud save** to power real social features across devices.
