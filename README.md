# Get It Done

![Swift](https://img.shields.io/badge/Swift-5-orange?logo=swift&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-iOS-blue?logo=apple&logoColor=white)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-Proprietary-red)

A social fitness challenge app that turns working out into a competitive, community-driven experience. Create challenges, stake tokens, check in with GPS verification, and hold your friends accountable.

---

## Screenshots

<p align="center">
  <img src="screenshots/login.png" width="200" alt="Login Screen"/>
  <img src="screenshots/feed.png" width="200" alt="Challenge Feed"/>
  <img src="screenshots/challenge_detail.png" width="200" alt="Challenge Detail"/>
  <img src="screenshots/checkin.png" width="200" alt="Check-In with Map"/>
</p>
<p align="center">
  <img src="screenshots/create_challenge.png" width="200" alt="Create Challenge"/>
  <img src="screenshots/friends.png" width="200" alt="Friends"/>
  <img src="screenshots/profile.png" width="200" alt="Profile"/>
  <img src="screenshots/settings.png" width="200" alt="Settings"/>
</p>

---

## Features

### Challenges
- Create fitness challenges with customizable duration, type (Strength, Cardio, Legs), and token stakes
- Set challenges as public or private and invite friends
- Browse and join public challenges from the community feed
- Track participant progress in real time

### Location-Verified Check-Ins
- Attach a location to any challenge using an interactive map picker
- Check-ins are verified via GPS with a 150-meter proximity threshold
- Non-location challenges support simple one-tap check-ins

### Token Economy
- Start with 1,250 tokens and stake them on challenges to stay accountable
- View full transaction history for all token activity
- Add tokens through the settings panel

### Social
- Follow friends and discover new users through suggestions
- View anyone's profile, stats, and active challenges
- Public challenges appear in a shared feed with creator attribution

### Profile & Settings
- Edit your name, username, and profile photo (camera or photo library)
- Photos stored in Firebase Storage
- App-wide dark mode toggle (persisted via UserDefaults)
- Notification preferences with system permission handling

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Language** | Swift 5 |
| **UI** | UIKit, Storyboards, Auto Layout |
| **Auth** | Firebase Authentication |
| **Database** | Cloud Firestore |
| **Storage** | Firebase Storage |
| **Maps** | MapKit, CoreLocation |
| **Notifications** | UserNotifications |
| **Package Manager** | Swift Package Manager |

---

## Architecture

```
├── Models
│   ├── UserProfile          # User account data
│   ├── Challenge             # Challenge configuration & metadata
│   ├── ChallengeParticipant  # Per-user progress tracking
│   ├── FriendUser            # Friend relationship
│   └── TokenTransaction      # Token ledger entry
│
├── Services
│   └── FirebaseService       # Singleton — all Auth, Firestore, and Storage calls
│
├── View Controllers
│   ├── Auth                  # Login, Sign Up
│   ├── Feed                  # Public challenge feed
│   ├── Challenges            # My challenges, create, detail, check-in
│   ├── Friends               # Friend list, suggestions, profiles
│   └── Settings              # Preferences, tokens, profile editing
│
└── Resources
    ├── Main.storyboard       # Full UI layout
    ├── Assets.xcassets        # Colors, icons
    └── GoogleService-Info     # Firebase config
```

The app follows **MVC** with a centralized **service layer** (`FirebaseService.shared`) that abstracts all backend operations. Async Firebase calls use `DispatchGroup` for coordination and dispatch back to the main thread for UI updates.

---

## Getting Started

### Prerequisites
- Xcode 16+
- iOS 18+ deployment target
- A Firebase project with Auth, Firestore, and Storage enabled

### Setup
1. Clone the repository
2. Open `PuduPranav-ProjectFinal.xcodeproj` in Xcode
3. Add your own `GoogleService-Info.plist` from the [Firebase Console](https://console.firebase.google.com)
4. Build and run on a simulator or device

### Demo Account
If using the included Firebase project:
```
Email:    test@example.com
Password: test123
```

---

## Navigation

The app uses a **Tab Bar Controller** with four main sections:

| Tab | Screen | Description |
|-----|--------|-------------|
| **Feed** | `FeedViewController` | Browse public challenges from the community |
| **Challenges** | `ChallengesViewController` | View and manage your joined challenges |
| **Friends** | `FriendsViewController` | Discover users and manage your friend list |
| **Settings** | `SettingsViewController` | Dark mode, notifications, tokens, profile |

---

## License

This project is proprietary software. See [LICENSE](LICENSE) for details.

---

Built by **Pranav Pudu**
