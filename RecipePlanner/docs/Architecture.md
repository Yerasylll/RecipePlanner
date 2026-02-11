# Architecture Documentation - Recipe Planner

## Overview
Recipe Planner uses **MVVM + Repository** pattern with clean architecture principles.

## Architecture Diagram
```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (SwiftUI)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │  Login   │  │   Feed   │  │ Details  │  │ Profile  │ │
│  │  View    │  │   View   │  │   View   │  │   View   │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘ │
│       │             │              │             │        │
│       ▼             ▼              ▼             ▼        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │   Auth   │  │   Feed   │  │ Details  │  │ Profile  │ │
│  │ViewModel │  │ViewModel │  │ViewModel │  │ViewModel │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘ │
└───────┼─────────────┼──────────────┼─────────────┼───────┘
        │             │              │             │
        ▼             ▼              ▼             ▼
┌──────────────────────────────────────────────────────────┐
│                  Repository Layer                         │
│  ┌──────────────────┐  ┌──────────────────┐             │
│  │     Recipe       │  │    Comment       │             │
│  │    Repository    │  │   Repository     │             │
│  └────────┬─────────┘  └────────┬─────────┘             │
└───────────┼─────────────────────┼────────────────────────┘
            │                     │
            ▼                     ▼
┌──────────────────────────────────────────────────────────┐
│                    Data Sources                           │
│  ┌────────────┐  ┌────────────┐  ┌──────────────────┐   │
│  │   Remote   │  │   Local    │  │    Firebase      │   │
│  │   (API)    │  │ (CoreData) │  │  (Realtime DB)   │   │
│  └────────────┘  └────────────┘  └──────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

## Data Flow

### Reading Data (Online)
1. View calls ViewModel method
2. ViewModel calls Repository
3. Repository calls Remote Data Source (API)
4. API returns data
5. Repository caches to Local Data Source (Core Data)
6. Repository returns data to ViewModel
7. ViewModel updates @Published properties
8. View updates automatically

### Reading Data (Offline)
1. View calls ViewModel method
2. ViewModel calls Repository
3. Repository catches network error
4. Repository falls back to Local Data Source (Core Data)
5. Cache data returned to ViewModel
6. ViewModel updates @Published properties
7. View updates automatically

### Realtime Updates (Firebase)
1. View subscribes to Firebase listener via Repository
2. Firebase sends updates through observer pattern
3. Repository receives update
4. ViewModel publishes update
5. View re-renders automatically

## Layer Responsibilities

### UI Layer
- **Views:** Display data and handle user interactions
- **ViewModels:** Business logic, state management, API coordination
- **Components:** Reusable UI elements

### Repository Layer
- Abstracts data sources from ViewModels
- Implements offline-first strategy
- Handles sync logic

### Data Layer
- **Remote:** API calls via URLSession
- **Local:** Core Data for offline storage
- **Firebase:** Real-time features (comments, favorites)

## Dependency Injection
```swift
class AppContainer {
    // Singleton pattern for DI
    static let shared = AppContainer()
    
    // Services
    lazy var apiClient = APIClient()
    lazy var firebaseService = FirebaseRealtimeService()
    
    // Repositories
    lazy var recipeRepository = RecipeRepository(
        apiClient: apiClient,
        localDataSource: localDataSource,
        firebaseService: firebaseService
    )
}
```

## Key Design Decisions

### 1. MVVM Pattern
**Why:** SwiftUI's reactive nature aligns perfectly with MVVM. @Published properties automatically update views.

### 2. Repository Pattern
**Why:** Separates data access from business logic. Makes testing easier and supports offline mode.

### 3. Offline-First Strategy
**Why:** Provides better UX on unstable connections. Data loads instantly from cache.

### 4. Firebase for Realtime
**Why:** Built-in real-time synchronization without custom WebSocket implementation.

## Sync Strategy

### Recipe Caching
- **Online:** Fetch from API → Save to Core Data
- **Offline:** Load from Core Data cache
- **Stale Check:** Timestamp-based (7 days)

### Favorites
- **Local:** Immediate update in Core Data
- **Remote:** Sync to Firebase
- **Conflict:** Last-write-wins

### Comments (Realtime)
- **Write:** Direct to Firebase
- **Read:** Firebase observer (live updates)
- **No local cache** (requires internet)

## Security Model

### API Keys
- Stored in `Secrets.xcconfig` (gitignored)
- Referenced in Info.plist via `$(SPOONACULAR_API_KEY)`

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
    }
  }
}
```

## Testing Strategy
- **Unit Tests:** Business logic (RecommendationEngine, validation)
- **Manual Tests:** UI flows, offline mode, real-time features
- **Integration:** API calls, Firebase sync