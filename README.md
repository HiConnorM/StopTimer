# Stop Timer — Perfect Second Challenge

A native iOS SwiftUI precision game. You see a target time, tap **Start**, the timer goes
**hidden**, and you tap **Stop** when you think it hit the target. The app reveals how close you
were, grades you, and pays out XP / coins / combo — all saved locally.

This is the first playable MVP: **Classic mode**, full Home → Game → Result → Profile → Settings
flow, local progression, and grade-based haptics. No backend, ads, IAP, or accounts.

---

## How to open & run (Simulator)

1. Open `StopTimer.xcodeproj` in Xcode (26.x).
2. Pick an iPhone simulator (e.g. **iPhone 17**) in the scheme/destination selector.
3. Press **⌘R**.

Or from the command line:

```bash
xcodebuild -project StopTimer.xcodeproj -scheme StopTimer \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build

xcrun simctl install "iPhone 17" build/Build/Products/Debug-iphonesimulator/StopTimer.app
xcrun simctl launch "iPhone 17" com.stoptimer.app
```

**Play:** Home → **PLAY** → see the target → **START** (timer hides, orb pulses) → **STOP** →
read your grade and rewards → **RETRY** (same target) / **NEXT** (new target) / **Home**. Your
stats persist across launches; check the **Profile** tab.

## How to run on a physical iPhone

1. Connect the iPhone, select it as the run destination.
2. Project → target **StopTimer** → **Signing & Capabilities** → check **Automatically manage
   signing** and pick your **personal team** (a free Apple ID works).
3. Xcode may rewrite the bundle id to be unique to your team — that's fine.
4. Press **⌘R**. On the phone, trust the developer profile under
   **Settings → General → VPN & Device Management** the first time.

> Haptics only fire on a real device — the Simulator does not vibrate.

---

## Project layout

File-system-synchronized Xcode group: every file under `StopTimer/` is automatically part of the
target, so adding new Swift files needs no project edits.

```
StopTimer/
  StopTimerApp.swift     @main; composition root (ProgressStore, SettingsViewModel, HapticsManager)
  Models/                AccuracyGrade, GameResult, RewardBundle, PlayerProgress, GameSettings
  Services/              PrecisionTimer, AccuracyScorer, TargetGenerator, RewardCalculator,
                         ProgressStore (UserDefaults+Codable), HapticsManager
  ViewModels/            GameViewModel, HomeViewModel, ProfileViewModel, SettingsViewModel
  Views/                 RootView, HomeView, GameView, ResultView, ProfileView, SettingsView
  Components/            PrimaryButton, StatCard, GradeBadge, TimerOrbView
  Utilities/             TimeFormatting, Constants
```

**Architecture:** one-directional MVVM —
`View → VM method → Service → @Published mutation → View re-render`.

**Precision rules (never bend):** time is always `Double` seconds; elapsed time is measured by a
monotonic clock (`DispatchTime.uptimeNanoseconds` in `PrecisionTimer`); scoring never reads a
SwiftUI/animation timer.

## Game rules (locked)

- **Target:** difficulty-ramped by lifetime attempts — whole seconds (3–10) for the
  first 5 rounds, then halves, tenths, and finally full precision (3.000–15.000).
- **Score:** `error = abs(actual - target)`, `signedDifference = actual - target`.
- **Grades:** ≤0.003 Legendary · ≤0.010 Perfect · ≤0.030 Excellent · ≤0.080 Great · ≤0.150 Good ·
  ≤0.300 Close · else Miss.
- **Rewards (XP/coins):** 100/50 · 75/35 · 50/25 · 30/15 · 15/8 · 5/3 · 1/0.
- **Combo:** Good-or-better increments; Close/Miss resets. Coins get a combo multiplier
  (×1.0 / ×1.1 / ×1.25 / ×1.5 at 0–4 / 5–9 / 10–19 / 20+); XP is never multiplied.

---

## Common errors & fixes

- **`'@main' attribute can only apply to one type`** — there should be exactly one `@main`
  (`StopTimerApp`). If you copied another `App`/`ContentView`, delete the duplicate.
- **`Cannot find 'X' in scope`** — the file isn't in the target. With the synchronized group this
  shouldn't happen; if you moved files out of `StopTimer/`, drag them back in.
- **Preview shows nothing / "failed to build"** — hit **Resume** above the canvas (⌥⌘P). Previews
  flake on save; the app itself still runs.
- **Signing fails on device** — set your personal **Team** under Signing & Capabilities (not needed
  for the Simulator).
- **No haptics** — expected in the Simulator; test on a real iPhone, and check
  **Settings → Haptics** is on.

## Verifying scoring quickly

In `GameViewModel.stopRound()` you can temporarily force `let elapsed = targetSeconds + 0.004` to
confirm it grades **Perfect**, then revert. (Formal `XCTest` cases for the grade thresholds, combo
reset, and reward math are the recommended next addition.)

---

## Tests

`StopTimerTests/` holds `XCTest` coverage for the scoring core, reward table, combo
growth/reset, and the `ProgressStore` save/load round-trip. Run in Xcode with **⌘U**, or:

```
xcodebuild test -project StopTimer.xcodeproj -scheme StopTimer \
  -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
```

## Progression, store & stages

- **Closeness rewards** — every stop earns XP/coins scaled by `GameResult.closeness`
  (`maxRewardWindow = max(0.75, target*0.12)`), plus a grade bonus. Result screen shows an
  "% Accurate" meter and an encouraging line on near misses.
- **Stage ladder** — `StageCatalog` builds each stage deterministically (target, required accuracy,
  distraction level, bonus XP). Clear a stage by hitting its required accuracy to unlock the next.
  Pick stages from Home → Choose Stage.
- **Store** — spend coins on cosmetics (orbs, backgrounds, buttons, result effects, titles). Owned
  + equipped state is saved locally in `PlayerProgress` (forward-compatible `Codable`). The default
  button stays candy red.
- **Distractions** — higher stages layer escalating, purely-decorative effects
  (`DistractionOverlayView`), never blocking the Stop orb and fully disabled under Reduced Motion.

## Leaderboard (local placeholder)

The **Ranks** tab shows a composite rating — `PlayerProgress.leaderboardRating` (stage progression +
best-error precision + a little from perfects) — with the player placed against seeded sample
players. The UI talks only to the `LeaderboardService` protocol, so it swaps to a real source
without touching the view: implement `LeaderboardService` with **Game Center (GameKit)** or a backend
and inject it into `LeaderboardViewModel`. Until then it's clearly labeled a preview (not truly global).

## Achievements & prestige cosmetics

Money buys style; **skill earns status**. `AchievementCatalog` defines skill-based achievements
(0.001 Club, Perfect 10, Ice Blooded, Apex Timer, Sharpshooter, …); each grants a **prestige
cosmetic** (`earnedOnly` title / badge / profile frame) that can never be bought. Streaks
(`bestPerfectStreak`, `bestNoMissStreak`) are tracked in `PlayerProgress`; `ProgressStore.refreshAchievements()`
awards new ones after each round and the result screen celebrates them. See the **Achievements**
screen (Profile → Achievements) for earned/locked state with progress bars; equip badges/frames from
the Store, shown on your Profile.

## Game modes & juice

- **Modes** (`GameMode`, chosen from the Home "Game Modes" grid): **Classic** (stage ladder),
  **Endless** (3 lives — Close/Miss costs a life, streak grows on Good+), and **Tap Rush** (mash the
  button for 5s; score = tap count, best saved). Each mode flow is its own view model; per-round
  precision still feeds lifetime stats/achievements.
- **Look** — glossy "casual mobile" pill buttons (`GlossyPillStyle`: saturated gradient, bold dark
  outline, diagonal shine) plus glossy mode cards.
- **Juice** — full-screen `ConfettiView` on wins (stage clear, top grade, new best, achievement),
  `LoseFlashView` + shake on losses, springy press feedback + light haptics everywhere.

## What to build next

1. **More modes** — Blitz (1–4s), Perfect Hunt, Daily Global on the same `GameMode` plumbing.
2. **Ranked + seasons** — 10-round sets scored by average accuracy + consistency; weekly resets with
   seasonal prestige cosmetics (reuses the achievement/prestige plumbing).
3. **Make the leaderboard real** — a `GameCenterLeaderboardService` (or backend) behind the existing
   `LeaderboardService` protocol.
4. **Beta** — TestFlight, screenshots, App Store copy.

Already in: bright-arcade UI + rich home hub, stage ladder, closeness-based rewards + accuracy meter,
cosmetic store, distractions, difficulty-ramped targets, glossy 3D buttons, tap-the-orb-to-stop,
grade-based haptics, result juice, native share, and unit tests.

Deliberately **not** in this MVP: backend, accounts, cloud save, Game Center, leaderboards, ads,
IAP/StoreKit, multiplayer, push, season pass.
