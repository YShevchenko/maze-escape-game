# Maze Escape - Requirements Document

## Game Overview

**Name:** Maze Escape
**Genre:** Puzzle / Logic
**Platform:** iOS, Android
**Type:** Offline-only, Privacy-first
**Monetization:** None (100% Free)

---

## Core Concept

A classic maze puzzle game where players navigate from the start (top-left) to the exit (bottom-right) in the shortest time possible. Each maze is procedurally generated, ensuring unique challenges every playthrough.

---

## Unique Requirements

### 1. Offline-Only ✅ CRITICAL
- **MUST work 100% offline**
- **NO network connectivity required**
- **NO external dependencies that enable network access**
- **MUST function in airplane mode**
- All data stored locally on device
- No cloud sync, no remote APIs, no web services

### 2. Privacy-First ✅ CRITICAL
- **NO data collection of any kind**
- **NO analytics or tracking**
- **NO third-party SDKs that track users**
- **NO personal information required**
- All settings and scores stored locally only
- Cannot transmit data even if user wanted to

### 3. Zero Monetization ✅
- **NO in-app purchases**
- **NO advertisements**
- **NO premium features**
- **NO subscriptions**
- Completely free, no hidden costs

---

## Technical Requirements

### Platforms
- iOS 12.0+
- Android API 21+ (Android 5.0 Lollipop)

### Dependencies (Allowed)
- ✅ `shared_preferences` - Local storage only
- ✅ `share_plus` - Native share dialog (no network)
- ✅ `in_app_review` - Native review prompt (no network)
- ✅ Flutter SDK components

### Dependencies (Forbidden)
- ❌ Firebase (all products)
- ❌ AdMob / Google Mobile Ads
- ❌ Analytics packages
- ❌ url_launcher (enables web browsing)
- ❌ http / dio (network requests)
- ❌ Any cloud services
- ❌ Any tracking SDKs

### Permissions
**Android:**
- NO INTERNET permission in release manifest
- OK for debug/profile builds (Flutter development)

**iOS:**
- No network usage description keys
- No background modes

---

## Game Mechanics

### Maze Generation
- Algorithm: Depth-first search with recursive backtracking
- Guarantees solvable maze every time
- Three difficulty levels:
  - **Easy:** 8x8 grid
  - **Medium:** 12x12 grid
  - **Hard:** 16x16 grid

### Controls
- Four directional buttons (Up, Down, Left, Right)
- Movement blocked by walls
- Tap or click to move

### Scoring
- Time-based (lower is better)
- Timer starts when game begins
- Stops when player reaches exit
- Best time saved as high score

### Achievements
Time-based achievements:
1. **Quick Escape** - Complete in under 30 seconds
2. **Maze Runner** - Complete in under 20 seconds
3. **Speed Demon** - Complete in under 15 seconds
4. **Legendary** - Complete in under 10 seconds

---

## User Interface

### Screens
1. **Menu Screen**
   - Game title with animated icon
   - Best time display
   - Three difficulty buttons
   - Settings button
   - Help button

2. **Game Screen**
   - Maze canvas (centered)
   - Timer display in app bar
   - Pause button
   - Arrow control buttons
   - Pause overlay when paused

3. **Completion Screen**
   - Success message
   - Final time
   - New record indicator (if applicable)
   - Back to menu button
   - Share time button

4. **Settings Screen**
   - Sound effects toggle
   - Vibration toggle
   - Achievements list link
   - Privacy policy (local dialog)
   - Version info

5. **Achievements Screen**
   - List of all achievements
   - Locked/unlocked status
   - Achievement descriptions

### Visual Design
- **Player:** Green circle
- **Exit:** Red circle
- **Walls:** White lines
- **Background:** Dark theme
- **Colors:** Purple primary, Amber secondary

### Dark Mode
- MUST support system theme detection
- Automatically switches between light/dark
- Uses Material Design 3 themes

---

## Audio

### Sound Effects
- Uses system sounds (SystemSound API)
- Click sound on player movement
- Alert sound on achievement unlock
- Heavy haptic on maze completion

### Settings
- User can toggle sound on/off
- User can toggle vibration on/off
- Preferences saved locally

---

## Data Storage

### Local Storage (SharedPreferences)
Stored data:
- `sound`: boolean - Sound effects enabled
- `vibration`: boolean - Vibration enabled
- `highScore`: int - Best time in seconds (999999 = no score)
- `gamesPlayed`: int - Total games completed
- `hasSeenTutorial`: boolean - Tutorial shown flag
- `achievements`: List<String> - Unlocked achievement IDs

### No Cloud Storage
- No Firebase Firestore
- No remote databases
- No cloud sync
- All data stays on device forever

---

## Privacy Policy

**Full Text (shown in-app):**

> Maze Escape is a 100% offline game.
>
> We do NOT collect, store, or transmit any personal data.
>
> All game data (scores, settings, achievements) is stored locally on your device and never leaves your device.
>
> We do NOT use:
> - Analytics or tracking
> - Advertising networks
> - Third-party services
> - Internet connectivity
>
> This app works completely offline and respects your privacy.

---

## Performance Requirements

### Frame Rate
- Minimum 60 FPS on target devices
- No lag during maze generation
- Smooth canvas drawing

### App Size
- Target: < 20 MB
- No unnecessary assets
- Optimized images

### Battery Usage
- Minimal battery drain
- No background processes
- Efficient rendering

---

## Testing Requirements

### Offline Testing
1. Test in airplane mode
2. Test without WiFi/cellular
3. Verify no network calls
4. Confirm all features work offline

### Device Testing
- iOS: Test on iPhone SE (low-end) and latest iPhone
- Android: Test on API 21 device and latest flagship
- Verify performance on all difficulty levels

### Regression Testing
- Test after every dependency update
- Verify no analytics accidentally added
- Check manifest for new permissions

---

## App Store Requirements

### Metadata
- **Publisher:** Heldig Lab
- **Contact Email:** heldig.lab@pm.me
- **Category:** Games / Puzzle
- **Price:** Free
- **In-App Purchases:** None

### Privacy Declarations
- Data Not Collected
- No third-party data sharing
- No tracking across apps/websites

### Screenshots Needed
- Menu screen
- Easy difficulty gameplay
- Hard difficulty gameplay
- Achievements screen
- Completion celebration

### Keywords
- maze
- puzzle
- offline
- logic
- brain teaser
- strategy
- challenge
- labyrinth

---

## Version History

### v1.0.0 (Current)
- Initial release
- Three difficulty levels
- Achievement system
- Offline-only design
- Dark mode support
- Privacy-first approach

---

## Future Considerations (Out of Scope for v1.0)

### Potential Features (All Must Remain Offline)
- Custom difficulty (user-selectable grid size)
- Swipe gesture controls
- Mini-map / maze preview
- Hint system (show optimal path)
- Daily challenge (seeded random generation)
- Color theme customization
- Maze export as image (local only)

### Will NEVER Add
- Online multiplayer
- Leaderboards (requires cloud)
- Social features (requires network)
- Any form of monetization
- Analytics or tracking

---

## Success Metrics (Offline Tracking Only)

Can track locally (no server):
- Games played count
- Average completion time
- Achievement unlock rate
- Settings usage patterns

Cannot track (requires network):
- Daily active users
- Retention rate
- Crash analytics
- User demographics

**Philosophy:** If we can't track it offline, we don't need to know it.

---

## Compliance Checklist

Before each release, verify:

- [ ] No Firebase configuration files
- [ ] No AdMob SDK
- [ ] No analytics packages
- [ ] No network permissions (release manifest)
- [ ] No url_launcher or http packages
- [ ] Flutter analyze passes
- [ ] Test works 100% in airplane mode
- [ ] Privacy policy accurate
- [ ] App Store privacy declarations correct
- [ ] No data leaves device

---

## Contact

**Developer:** Heldig Lab
**Email:** heldig.lab@pm.me
**Philosophy:** Privacy-first, offline-only, user-respecting software

---

**Document Version:** 1.0
**Last Updated:** April 3, 2026
**Status:** Approved for Implementation
