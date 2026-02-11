# Recipe Planner - iOS

> Discover recipes, plan meals, save favorites, and discuss recipes in real-time

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Screenshots

[Add 3-4 screenshots here showing: Feed, Recipe Details, Meal Planning, Profile]

## Features

### Core Features
- **Smart Search** - Find recipes with debounced search (500ms delay)
- **Infinite Scroll** - Pagination with 20 recipes per page
- **Favorites** - Save recipes across devices with Firebase sync
- **Real-time Comments** - Discuss recipes with live updates
- **Ratings & Reviews** - 5-star rating system with written reviews
- **Meal Planning** - Calendar-based meal scheduling
- **Offline Mode** - View cached recipes without internet
- **Profile Management** - Edit username and password

### Technical Features
- **MVVM Architecture** - Clean separation of concerns
- **Core Data Caching** - Offline-first with intelligent sync
- **Firebase Integration** - Auth + Realtime Database
- **Image Caching** - Fast loading with Kingfisher
- **Async/Await** - Modern Swift concurrency
- **Unit Tested** - 10 comprehensive tests
- **Secure** - API keys properly managed

## Tech Stack

- **Language:** Swift 5.9
- **UI Framework:** SwiftUI
- **Architecture:** MVVM + Repository Pattern
- **Persistence:** Core Data
- **Networking:** URLSession (async/await)
- **Images:** Kingfisher
- **Backend:** Firebase (Auth + Realtime Database)
- **API:** Spoonacular Recipe API

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- CocoaPods or Swift Package Manager

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/RecipePlanner.git
cd RecipePlanner
```

### 2. Install Dependencies

#### Using Swift Package Manager (Recommended)

Dependencies are automatically resolved by Xcode:
- Firebase iOS SDK (Auth, Database, Analytics)
- Kingfisher

Simply open the project:
```bash
open RecipePlanner.xcodeproj
```

### 3. Configure API Keys

#### Spoonacular API

1. Get your free API key from [Spoonacular](https://spoonacular.com/food-api)
2. Create `Config/Secrets.xcconfig`:
```bash
cp Config/Secrets.xcconfig.template Config/Secrets.xcconfig
```

3. Edit `Config/Secrets.xcconfig`:
```
SPOONACULAR_API_KEY = your_api_key_here
```

#### Firebase Configuration

1. Create a project in [Firebase Console](https://console.firebase.google.com/)

2. Enable **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

3. Enable **Realtime Database**:
   - Go to Realtime Database → Create Database
   - Start in **Test Mode** (for development)
   - Choose location (e.g., us-central1)

4. Add iOS app:
   - Project Settings → Add app → iOS
   - Bundle ID: `com.yourname.RecipePlanner`
   - Download `GoogleService-Info.plist`

5. Add `GoogleService-Info.plist` to project:
   - Drag file into Xcode
   - Ensure "Copy items if needed" is checked
   - Target: RecipePlanner

### 4. Configure Xcode Project Settings

1. Open `RecipePlanner.xcodeproj`
2. Select project → Info tab
3. Under **Configurations**, set:
   - Debug → `Debug.xcconfig`
   - Release → `Release.xcconfig`

### 5. Build and Run
```bash
# Select simulator or device
# Press Cmd + R to build and run
```

## Project Structure
```
RecipePlanner/
├── App/                         # App entry point
│   ├── RecipePlannerApp.swift  # Main app file
│   └── AppContainer.swift      # Dependency injection
│
├── Data/                        # Data layer
│   ├── Network/                # API client
│   ├── Local/                  # Core Data
│   ├── Firebase/               # Firebase services
│   └── Repository/             # Repository pattern
│
├── Domain/                      # Business logic
│   ├── Models/                 # Data models
│   └── BusinessLogic/          # Business rules
│
├── UI/                          # Presentation layer
│   ├── Auth/                   # Login/Register
│   ├── Feed/                   # Recipe list
│   ├── Details/                # Recipe details
│   ├── Search/                 # Search functionality
│   ├── Favorites/              # Saved recipes
│   ├── Profile/                # User profile
│   └── Components/             # Reusable UI
│
├── Resources/                   # Assets & config
│   ├── Assets.xcassets
│   ├── RecipeModel.xcdatamodeld
│   ├── GoogleService-Info.plist
│   └── Info.plist
│
├── Tests/                       # Unit tests
│   └── RecipePlannerTests/
│
└── docs/                        # Documentation
    ├── ARCHITECTURE.md
    ├── RELEASE_NOTES.md
    ├── MANUAL_TEST_CHECKLIST.md
    ├── QA_LOG.md
    └── PERFORMANCE_NOTE.md
```

## Architecture

### MVVM + Repository Pattern
```
View → ViewModel → Repository → Data Sources
                                  ├── Remote (API)
                                  ├── Local (Core Data)
                                  └── Firebase
```

**Read full architecture documentation:** [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

### Key Design Decisions

1. **Offline-First:** All recipes cached in Core Data
2. **Reactive UI:** SwiftUI + Combine for automatic updates
3. **Dependency Injection:** AppContainer manages dependencies
4. **Clean Separation:** UI never directly accesses data sources

## Security

### API Key Management
- API keys stored in `Config/Secrets.xcconfig` (gitignored)
- Never commit `Secrets.xcconfig` or `GoogleService-Info.plist`

### Firebase Security Rules
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "comments": {
      ".read": true,
      "$recipeId": {
        ".write": "auth != null"
      }
    },
    "ratings": {
      ".read": true,
      "$recipeId": {
        "$userId": {
          ".write": "$userId === auth.uid"
        }
      }
    }
  }
}
```

## Testing

### Run Unit Tests
```bash
# In Xcode
Cmd + U
```

### Test Coverage
- 10 unit tests covering:
  - Business logic (RecommendationEngine)
  - Validation (Email, Password, Rating)
  - Data operations (Pagination, Caching)
- 25-item manual test checklist

**See:** [docs/MANUAL_TEST_CHECKLIST.md](docs/MANUAL_TEST_CHECKLIST.md)

## Performance

### Optimizations
- **Image Caching:** 86% reduction in data usage
- **Pagination:** Load only 20 recipes at a time
- **Debounced Search:** Reduce API calls by 90%
- **Core Data Indexing:** Fast favorite lookups

**Evidence:** [docs/PERFORMANCE_NOTE.md](docs/PERFORMANCE_NOTE.md)

## Known Issues

1. Comments require internet (not cached locally)
2. Meal plans limited to 90 days ahead
3. Image loading delay on very slow networks (<100kbps)

## Release Notes

### Version 1.0 (Current)
- Initial release with all core features
- 5-star rating system
- Calendar meal planning
- Profile editing
- Recently viewed recipes

**Full changelog:** [docs/RELEASE_NOTES.md](docs/RELEASE_NOTES.md)

## Contributing

This is an academic project for **Astana IT University - Native Mobile Development**.

### Team
- **Developers:** Yerasyl Alimbek, Nazerke Abdizhamal
- **Course:** Native Mobile Development (iOS/Android)


## Acknowledgments

- **API:** [Spoonacular Recipe API](https://spoonacular.com/food-api)
- **Backend:** [Firebase](https://firebase.google.com)
- **Image Loading:** [Kingfisher](https://github.com/onevcat/Kingfisher)
- **AI Assistance:** Claude AI for boilerplate and architecture guidance

## Repository  
GitHub repository: [https://github.com/Yerasylll/RecipePlanner.git](https://github.com/Yerasylll/RecipePlanner.git)
