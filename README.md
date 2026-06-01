# 🐱 AllAboutCats: iOS Code Assessment

A native iOS application that fetches and displays cat breed information from [TheCatAPI](https://thecatapi.com), built as part of an engineering assessment.

***

## 📱 Screenshots

> List view showing a two-column breed grid with images, names, and origins. Tapping a breed opens a detail screen with photo, weight, life span, description, and temperament tags.
<table>
  <tr>
<td><img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-01 at 14 28 57" src="https://github.com/user-attachments/assets/2f62d0d1-12be-45ea-a531-b30bcf3298f6" width="300"/></td>
<td><img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-01 at 14 29 11" src="https://github.com/user-attachments/assets/f9a95bda-5a5a-40cd-aa9f-fbb16ddde76d" width="300"/></td>
  </tr>
  <tr>
    <td align="center">Breed List</td>
    <td align="center">Breed Detail</td>
  </tr>
</table>


***

## 🧩 Problem & Solution

**Problem:** Build an iOS app that fetches a paginated list of cat breeds from a REST API and displays them in a polished, native UI following up-to-date iOS practices.

**Solution:** A SwiftUI application using Swift Concurrency (`async/await`) with an MVVM architecture and a clean service layer. The app fetches 12 breeds per page from TheCatAPI, displays them in a responsive two-column grid, and navigates to a detail screen for each breed. API key security was treated as a first-class concern.

***

## 🏗 Architecture

The project follows **MVVM** with a clean separation between the network layer, business logic, and UI.

```
AllAboutCats/
├── AllAboutCatsApp.swift           App entry point
├── Info.plist                      Contains $(CAT_API_KEY) reference
│
├── CatInfoView/
│   ├── CatInfoView.swift           Breed detail screen
│   └── CatInfoViewModel.swift      State management for breed detail
│
├── CatsList/
│   ├── CatsListView.swift          Two-column breed grid
│   └── CatsListViewModel.swift     State management for breed list
│
├── Models/
│   ├── CatBreed.swift              Root breed model + computed helpers
│   ├── CatImage.swift              Image model
│   └── Weight.swift                Weight model (imperial + metric)
│
├── Services/
│   └── CatAPIService.swift         Protocol + live network implementation
│
├── Components/
│   ├── BreedCard.swift             Card used in the breeds grid
│   ├── CatAsyncImageView.swift     Reusable async image with shimmer & fallback
│   ├── ShimmerView.swift           Reusable animated shimmer loading effect
│   ├── SkeletonCard.swift          Placeholder card shown during loading
│   └── StatBadge.swift             Stat pill used in the detail screen
│
└── Assets.xcassets                 App icons and color assets
```

### Data Flow

```
CatsListView
    │  observes
    ▼
CatsListViewModel (@MainActor)
    │  depends on
    ▼
CatAPIServiceProtocol
    │  implemented by
    ▼
CatAPIService ──► URLSession ──► TheCatAPI
    │
    ▼
[CatBreed] ──► CatBreed (with CatImage + Weight)

    tap breed
    │
    ▼
CatInfoView
    │  observes
    ▼
CatInfoViewModel (@MainActor)
    │  reads from
    ▼
CatBreed (already fetched, no extra request needed)
```

### SOLID Principles Applied

| Principle | Implementation |
|---|---|
| **Single Responsibility** | Each file has one job, `CatAPIService` handles networking, ViewModels handle state, each component in `Components/` renders one thing |
| **Open / Closed** | `CatAPIServiceProtocol` is open to extension without modifying existing code |
| **Liskov Substitution** | Any conformer of `CatAPIServiceProtocol` substitutes the live service without breaking behaviour |
| **Interface Segregation** | `CatAPIServiceProtocol` exposes only what ViewModels need — no unused methods |
| **Dependency Inversion** | ViewModels depend on `CatAPIServiceProtocol`, not the concrete `CatAPIService` |

***

## 🛠 Technical Choices

### Language & Framework
- **Swift 5.9 + SwiftUI**: Fully native, declarative UI following the latest Apple HIG
- **Swift Concurrency (`async/await`)**: Structured concurrency for all async work; `@MainActor` on ViewModels guarantees UI updates on the main thread
- **No third-party libraries**: `URLSession`, `AsyncImage`, and `LazyVGrid` cover all requirements without adding dependency overhead

### Networking
- `CatAPIServiceProtocol` abstracts the network layer, ViewModels never depend on the concrete implementation
- `JSONDecoder` with `.convertFromSnakeCase` maps the API's `snake_case` keys to Swift's `camelCase` automatically
- API key injected via the `x-api-key` **HTTP header**, never in the URL (query params appear in server logs and crash reporters)

### State Management
ViewModels expose a `State` enum, giving the View a single source of truth with no ambiguous boolean combinations:

```swift
enum State {
    case idle
    case loading
    case loaded
    case error(String)
}
```

### Component Separation
`BreedCard`, `ShimmerView`, `SkeletonCard`, and `StatBadge` each live in their own file under `Components/`, making them:
- **Independently reusable** across any future screen
- **Easy to preview in isolation** via `#Preview`
- **Clearly scoped** one file, one responsibility

### Image Loading
`AsyncImage` handles loading with three explicitly designed states:
- **Loading**: animated `ShimmerView` skeleton
- **Success**: smooth `.easeIn` fade-in transition
- **Failure**: friendly paw-print placeholder

The hero image in `CatInfoView` is a **fully independent layout block** from the info section, its dimensions can never cause text or badges to bleed off-screen regardless of the source image size.

***

## 🔐 API Key Security

The API key is never hard-coded in source. The security chain:

1. Raw key lives in `Config/Debug.xcconfig`  **excluded from git via `.gitignore`**
2. `Info.plist` stores only the variable reference: `$(CAT_API_KEY)`
3. Xcode substitutes the real value at **build time**, source repo never contains the key
4. At runtime, `CatAPIService` reads the key from `Bundle.main` via `object(forInfoDictionaryKey:)`
5. Key is sent exclusively in the `x-api-key` **request header**: not in query parameters

```swift
// Key never appears in the URL
request.setValue(key, forHTTPHeaderField: "x-api-key")
```

***

## ✅ Features

- Two-column lazy grid of cat breeds with photo, name, and origin
- Detail screen showing breed photo, weight (metric), life span, description, and temperament chips
- Animated shimmer skeleton while data loads
- Error screen with retry action
- `ContentUnavailableView` for error states (iOS 17+)
- Graceful image fallback using `referenceImageId` CDN URL when the embedded image is absent
- Optional fields handled safely, the API omits some fields for certain breeds

***

## ⚖️ Trade-offs

- **Pagination:** Only page 1 (12 breeds) is loaded. Infinite scroll with `onAppear` on the last item would extend this — the ViewModel's `page` and `limit` parameters are already in place.
- **Image caching:** `URLSession`'s built-in `URLCache` is used implicitly. A dedicated `NSCache<NSURL, UIImage>` layer would give finer memory control.
- **No offline support:** The app requires a network connection. SwiftData persistence would enable offline browsing.
- **No mock service:** A `MockCatAPIService` was not implemented within the time constraint, but the `CatAPIServiceProtocol` abstraction means it can be added with zero changes to existing ViewModels.

***

## 🚀 Possible Improvements

- [ ] Infinite scroll / pagination
- [ ] Search and filter by name, origin, or temperament
- [ ] Favourites persisted with SwiftData
- [ ] `MockCatAPIService` for unit tests and SwiftUI Previews without hitting the real API
- [ ] Unit tests for ViewModels
- [ ] UI tests with `XCUITest`
- [ ] Full Keychain-backed API key storage
- [ ] Accessibility: VoiceOver labels on image cards
- [ ] iPad three-column layout

***

## 🔧 Setup

### Requirements
- Xcode 16+
- iOS 17+ deployment target
- A free API key from [thecatapi.com](https://thecatapi.com)

### Steps

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/AllAboutCats.git
   cd AllAboutCats
   ```

2. Create your local config file (gitignored)
   ```bash
   cp Config/Debug.xcconfig.example Config/Debug.xcconfig
   ```

3. Open `Config/Debug.xcconfig` and add your key
   ```
   CAT_API_KEY = live_your_key_here
   ```

4. Open `AllAboutCats.xcodeproj` in Xcode and run

> **Note:** The app will show an error screen if `CAT_API_KEY` is missing or empty.

***

## 📡 API Reference

| Endpoint | Usage |
|---|---|
| `GET /v1/breeds?page=1&limit=12` | Fetch paginated breed list |
| `GET /v1/images/search?limit=1&breed_ids={id}` | Fetch image for a specific breed |

Base URL: `https://api.thecatapi.com/v1`
Authentication: `x-api-key` header

***

## 🧪 Testability

Because ViewModels depend on `CatAPIServiceProtocol`, a mock can be injected with no changes to any existing file:

```swift
final class MockCatAPIService: CatAPIServiceProtocol {
    var breedsResult: Result<[CatBreed], Error> = .success([])
    func fetchBreeds(page: Int, limit: Int) async throws -> [CatBreed] {
        try breedsResult.get()
    }
}

// In tests:
let viewModel = CatsListViewModel(service: MockCatAPIService())
```

***

## 📄 License

This project was built as a code assessment and is not intended for production use.
