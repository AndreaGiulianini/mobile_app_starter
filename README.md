# Mobile App Starter - Flutter Pokédex

A modern Flutter application showcasing best practices for mobile development, featuring a Pokédex with infinite scroll, state management using BLoC/Cubit, and a clean architecture.

## 🚀 Features

- **State Management**: BLoC pattern with Cubit for predictable state handling
- **Infinite Scroll**: Efficient pagination with parallel API calls
- **Dependency Injection**: Get_it for clean dependency management
- **Type-safe Routing**: go_router with code generation
- **Environment Configuration**: Multiple environment support (.env files)
- **Theming**: Material 3 with light/dark mode support
- **Error Handling**: Custom exceptions with graceful fallbacks
- **Localization**: Easy localization support with easy_localization
- **Network Layer**: Dio with custom error handling and logging
- **Code Generation**: build_runner for routes and JSON serialization
- **Performance Optimized**: Widget keys, const constructors, and efficient rebuilds

## 📁 Project Structure

```
lib/
├── core/                           # Core functionality and configuration
│   ├── config/
│   │   └── app_config.dart        # Environment configuration (.env support)
│   ├── constants/
│   │   └── pokemon_type_colors.dart # Pokemon type color mappings
│   ├── di/
│   │   └── service_locator.dart   # Dependency injection setup (GetIt)
│   ├── errors/
│   │   └── app_exception.dart     # Custom exception classes
│   └── themes/
│       └── app_theme.dart         # Material 3 theme configuration
│
├── cubit/                          # State management (BLoC/Cubit)
│   ├── pokemon_cubit.dart         # Pokemon business logic
│   └── pokemon_state.dart         # Pokemon state classes
│
├── model/                          # Data models
│   ├── classes/
│   │   ├── pokemon.dart           # Pokemon model
│   │   └── pokemon.g.dart         # Generated JSON serialization
│   └── dtos/
│       ├── pokemon_dto.dart       # Data transfer objects
│       └── pokemon_dto.g.dart     # Generated JSON serialization
│
├── router/                         # Navigation
│   ├── routes.dart                # Route definitions (go_router)
│   └── routes.g.dart              # Generated routes
│
├── screens/                        # UI screens
│   └── pokedex_screen/
│       ├── pokedex_screen.dart    # Main Pokédex screen with infinite scroll
│       └── widgets/
│           └── pokemon_card.dart  # Pokemon card widget
│
├── service/                        # API and networking
│   ├── client.dart                # Base HTTP client (Dio)
│   └── pokemon_api.dart           # Pokemon API endpoints
│
├── utils/                          # Utilities
│   └── curl_logger.dart           # Network request logging
│
├── config.dart                     # Base configuration (DO NOT COMMIT)
└── main.dart                       # App entry point
```

## 🏗️ Architecture

### State Management (BLoC/Cubit)
- **Cubit Pattern**: Simplified BLoC for straightforward state management
- **Separation of Concerns**: Business logic separated from UI
- **Predictable State**: All state changes are traceable

### Dependency Injection
- **GetIt**: Service locator pattern for dependency management
- Registered in `lib/core/di/service_locator.dart`
- Singleton and factory patterns for different service lifecycles

### Routing
- **go_router**: Declarative routing with type safety
- **Code Generation**: Type-safe route parameters
- **Deep Linking**: Support for deep links

### Networking
- **Dio**: Powerful HTTP client with interceptors
- **Error Handling**: Custom exception mapping (NetworkException, ServerException, etc.)
- **Logging**: CURL logging in debug mode for easy API debugging

### Data Flow
```
UI (Screen) → Cubit → Service → API
     ↑           ↓
     └─── State ─┘
```

## 🔧 Setup and Installation

### Prerequisites
- Flutter SDK >=3.8.0 <4.0.0
- Dart SDK >=3.8.0
- Android Studio / Xcode (for mobile development)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mobile_app_starter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment files**
   
   The project uses environment files for configuration. Create the following files:
   
   - `.env` (default/development)
   - `.env.dev` (development)
   - `.env.staging` (staging)
   - `.env.prod` (production)
   
   Example `.env` file:
   ```env
   API_BASE_URL=https://pokeapi.co/api/v2
   ENVIRONMENT=development
   ```
   
   **⚠️ IMPORTANT**: Import `config.dart` manually as it contains sensitive data and is not committed to git.

4. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📝 Common Commands

### Code Generation
Generate routes and JSON serialization:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch mode for continuous generation:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Code Quality

Format all files (120 character line length):
```bash
dart format ./ -l 120
```

Apply automatic fixes:
```bash
dart fix --apply
```

Run analyzer:
```bash
flutter analyze
```

### Dependency Management

Check for available updates:
```bash
flutter pub upgrade --major-versions
```

Update dependencies:
```bash
flutter pub upgrade
```

Show outdated packages:
```bash
flutter pub outdated
```

### Building

Build debug APK:
```bash
flutter build apk --debug
```

Build release APK:
```bash
flutter build apk --release
```

Build iOS app:
```bash
flutter build ios --release
```

Clean build files:
```bash
flutter clean
```

## 🎨 Theming

The app uses Material 3 with custom Pokemon-themed colors:

- **Light Mode Primary**: #DC0A2D (Pokemon Red)
- **Light Mode Secondary**: #3B4CCA (Pokemon Blue)
- **Dark Mode Primary**: #FF1C1C (Lighter Red)
- **Dark Mode Secondary**: #5B7BDB (Lighter Blue)

Theme configuration is in `lib/core/themes/app_theme.dart`.

## 🌐 Localization

The app supports multiple languages using `easy_localization`:

- Translation files are in `assets/translations/`
- Add new languages by creating JSON files in the translations directory
- Language is automatically detected from device settings

## 📋 Code Guidelines

1. **Enum Placement**: Enums related to a component should be `part of` that component and placed in the same directory
2. **Warning-Free Code**: Remove all warnings possible
3. **Function Parameters**: Use only named parameters in functions
4. **Const Constructors**: Use `const` constructors wherever possible for performance
5. **Widget Keys**: Add keys to widgets in lists for efficient rebuilds
6. **State Management**: Keep business logic in Cubits, not in UI
7. **Error Handling**: Use custom exceptions, never swallow errors silently
8. **Theme Usage**: Always use theme colors instead of hardcoded values

## 🎯 Performance Best Practices

1. **Widget Keys**: All list items have `ValueKey` for efficient updates
2. **Const Constructors**: Static widgets use `const` to avoid rebuilds
3. **Lazy Loading**: Infinite scroll loads data progressively
4. **Parallel API Calls**: Multiple API requests are parallelized with `Future.wait`
5. **Image Caching**: `CachedNetworkImage` for efficient image loading
6. **Build Optimization**: Extracted constants to avoid recreating objects

## 🐛 Debugging

### Network Logging
In debug mode, all network requests are logged as CURL commands. Check the console for detailed request/response information.

### State Logging
BLoC transitions are logged in debug mode. Monitor state changes in the console.

### Flutter DevTools
Use Flutter DevTools for performance profiling, widget inspection, and debugging:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## 🔐 Security

- **Environment Variables**: Sensitive data stored in `.env` files (not committed)
- **Config File**: `config.dart` contains sensitive keys (not committed)
- **Release Signing**: Debug signing removed from release builds
- **ProGuard**: Enabled for release builds to obfuscate code

## 📱 Platform-Specific Configuration

### Android
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: Latest
- **Package**: com.starter.mobile_app
- **Build**: Gradle 8.13, AGP 8.13.2, Kotlin 2.2.21

### iOS
- **Deployment Target**: 13.0
- **Architecture**: arm64, x86_64

## 🤝 Contributing

1. Follow the code guidelines above
2. Run `flutter analyze` before committing
3. Format code with `dart format ./ -l 120`
4. Ensure all tests pass
5. Keep commits atomic and well-described

## 📄 License

[Add your license here]

## 👥 Authors

[Add author information here]

## 🙏 Acknowledgments

- PokeAPI for providing free Pokemon data
- Flutter and Dart teams for the amazing framework
- BLoC library maintainers
