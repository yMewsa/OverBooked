# 📚 Overbooked

> **Track your reading. Own your shelf.**

Overbooked is a beautiful, production-ready Flutter application that transforms your reading life into a virtual bookshelf experience — inspired by Letterboxd's approach to film logging, but built for books. Search millions of titles via Google Books, organize them across three curated shelves, and watch your reading statistics update automatically.

[![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![Provider](https://img.shields.io/badge/State-Provider-5C6BC0)](https://pub.dev/packages/provider)
[![Google Books](https://img.shields.io/badge/API-Google%20Books-4285F4?logo=google)](https://developers.google.com/books)

---

## 📸 Screenshots

<!-- Add screenshots here -->

---

## ✨ Features

| Feature | Description |
|---|---|
| 📖 **Three Shelves** | Organize books as *Lendo agora*, *Quero ler*, or *Lidos e resenhados* |
| 🔍 **Book Search** | Find any book using the Google Books API (title or author) |
| 🔐 **Authentication** | Secure email/password sign-up and login via Firebase Auth |
| ☁️ **Real-time Sync** | Firestore streams keep your shelf in sync across devices |
| 📊 **Auto Statistics** | A Cloud Function auto-calculates books read, pages read, and pages this month |
| ✏️ **Page Editor** | Manually enter/correct page counts via a 3-dot context menu |
| 📴 **Offline Handling** | Graceful UI for no connection, empty states, and API failures |

---

## 🏗️ Architecture Overview

The project follows a **layer-first** organization — every layer has a single responsibility.

```
overbooked/
├── lib/
│   ├── main.dart              # Entry point, MultiProvider, AuthGate
│   ├── firebase_options.dart  # ⚠️ Placeholder — generate with FlutterFire CLI
│   ├── theme/
│   │   └── app_theme.dart     # Colors, typography, ThemeData
│   ├── models/
│   │   ├── book.dart          # Book model + BookStatus constants
│   │   └── reading_stats.dart # ReadingStats model
│   ├── services/
│   │   ├── auth_service.dart      # FirebaseAuth wrapper
│   │   ├── firestore_service.dart # Firestore CRUD + streams
│   │   └── books_api_service.dart # Google Books HTTP client
│   ├── providers/
│   │   ├── auth_provider.dart       # Auth state (ChangeNotifier)
│   │   ├── bookshelf_provider.dart  # Books + search state
│   │   └── stats_provider.dart      # Reading stats state
│   ├── views/
│   │   ├── auth/
│   │   │   ├── login_view.dart
│   │   │   └── signup_view.dart
│   │   ├── bookshelf/
│   │   │   └── bookshelf_view.dart  # Tab 1 — Estantes
│   │   ├── stats/
│   │   │   └── stats_view.dart      # Tab 2 — Dados
│   │   ├── discover/
│   │   │   └── discover_view.dart   # Tab 3 — Descoberta
│   │   ├── profile/
│   │   │   └── profile_view.dart    # Tab 4 — Perfil
│   │   └── main_shell.dart          # BottomNavigationBar scaffold
│   └── widgets/
│       ├── book_card.dart       # Book cover card with 3-dot menu
│       ├── shelf_section.dart   # Labeled shelf row with wood divider
│       ├── stat_card.dart       # Single metric card
│       ├── add_book_sheet.dart  # Modal: add search result to shelf
│       └── edit_pages_sheet.dart # Modal: edit page count
├── functions/
│   ├── index.js      # Cloud Function (onBookStatusChanged)
│   └── package.json
├── firestore.rules   # Security rules
└── README.md
```

### State Management with Provider

Three `ChangeNotifier` providers are registered globally via `MultiProvider` in `main.dart`:

| Provider | Responsibility |
|---|---|
| `AuthProvider` | Listens to `FirebaseAuth.authStateChanges()`, exposes `user`, `isAuthenticated`, and async `signIn`/`signUp`/`signOut` methods |
| `BookshelfProvider` | Subscribes to the user's Firestore books collection via a stream. Exposes filtered getters (`readingNow`, `wantToRead`, `read`) and Google Books search results |
| `StatsProvider` | Subscribes to `/users/{userId}/stats/summary` in real time. Stats are written exclusively by the Cloud Function |

The root `AuthGate` widget uses `Consumer<AuthProvider>` to route between `LoginView` and `MainShell`. Once in `MainShell`, `initState` triggers `BookshelfProvider.init(userId)` and `StatsProvider.init(userId)` to begin streaming.

---

## 🔥 Firebase Database Schema

### `/users/{userId}/books/{bookId}`

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Google Books volume ID or UUID |
| `title` | `String` | Book title |
| `authors` | `List<String>` | List of author names |
| `coverUrl` | `String?` | HTTPS URL for book cover image |
| `pageCount` | `int?` | Number of pages (null if unknown) |
| `status` | `String` | `'want_to_read'` \| `'reading'` \| `'read'` |
| `updatedAt` | `Timestamp` | Last modification timestamp |
| `completedAt` | `Timestamp?` | When book was marked as read (for monthly stats) |

### `/users/{userId}/stats/summary`

| Field | Type | Description |
|---|---|---|
| `booksRead` | `int` | Cumulative count of books completed |
| `pagesRead` | `int` | Cumulative pages read across all books |
| `pagesReadThisMonth` | `int` | Pages read in the current calendar month |
| `lastUpdated` | `Timestamp` | When the function last wrote to this document |

---

## ⚡ Cloud Function Logic

The `onBookStatusChanged` function (in `functions/index.js`) fires on **every update** to a book document and:

1. **Checks** if the `status` field changed **to** `'read'` (ignores all other updates).
2. **Extracts** `pageCount` safely — defaults to `0` if the field is missing, null, or not a positive number.
3. **Determines** whether the completion date falls in the current calendar month (comparing `completedAt` year + month to today).
4. **Writes atomically** to `/users/{userId}/stats/summary` using `FieldValue.increment` — no race conditions, no data loss.
5. Uses `{ merge: true }` so the stats document is **created automatically** on first use.

```
Status changes to 'read'
        │
        ▼
Extract pageCount (safe, default 0)
        │
        ▼
Is completedAt this month?
   YES ──► increment booksRead, pagesRead, pagesReadThisMonth
   NO  ──► increment booksRead, pagesRead only
        │
        ▼
Atomic write to /users/{userId}/stats/summary
```

---

## 🚀 Setup Guide

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.3.0
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) (`dart pub global activate flutterfire_cli`)
- Node.js ≥ 20 (for Cloud Functions)
- A Google account with a Firebase project

---

### 1. Clone & Install Flutter Dependencies

```bash
# Clone the repository
git clone <your-repo-url>
cd overbooked

# Install Flutter packages
flutter pub get
```

---

### 2. Create Your Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **"Add project"** → name it (e.g., `overbooked`)
3. **Enable Google Analytics** (optional)

---

### 3. Configure Firebase Authentication

1. In Firebase Console → **Authentication** → **Get started**
2. Under **Sign-in method** → enable **Email/Password**

---

### 4. Configure Firestore

1. Firebase Console → **Firestore Database** → **Create database**
2. Start in **Production mode**
3. Choose a region close to your users

---

### 5. Generate `firebase_options.dart` (FlutterFire CLI)

```bash
# Login to Firebase
firebase login

# In your Flutter project root:
flutterfire configure
```

Select your Firebase project when prompted. This generates `lib/firebase_options.dart` with your app's credentials.

> **Note:** The existing `lib/firebase_options.dart` is a placeholder that throws at runtime. Replace it with the generated file.

---

### 6. Enable Google Books API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select the project linked to your Firebase app
3. Navigate to **APIs & Services** → **Enable APIs and Services**
4. Search for **"Books API"** and enable it
5. Create an API key under **Credentials**
6. In `lib/services/books_api_service.dart`, add your key:
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   // Then append: '&key=$_apiKey' to the URI queryParameters
   ```

> Without a key, the API works at a lower rate limit — fine for development.

---

### 7. Deploy Firestore Security Rules

```bash
# From the project root
firebase deploy --only firestore:rules
```

---

### 8. Deploy Cloud Functions

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

Verify in Firebase Console → **Functions** that `onBookStatusChanged` is listed.

---

### 9. Run the App

```bash
flutter run
```

For release builds:
```bash
flutter build apk --release      # Android
flutter build ios --release       # iOS (macOS required)
flutter build web --release       # Web
```

---

## 🛠️ Development Tips

- **Emulator Suite:** Use `firebase emulators:start` to test Functions and Firestore locally without touching production data.
- **Debug mode:** The `firebase_options.dart` placeholder will crash immediately — always generate the real file before running.
- **Hot reload:** Works fully with Provider — change UI code and see instant updates.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'feat: add my feature'`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

Please follow existing code style and run `dart format .` before committing.

---

## 📄 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ for readers everywhere.
</p>
