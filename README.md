# ChronoFlow

**ChronoFlow** is an Event Management platform built with Flutter using Clean Architecture, Bloc state management, and adaptive UI.

---

## Tech Stack

| Category             | Library                                                                    |
| -------------------- | -------------------------------------------------------------------------- |
| State Management     | [flutter_bloc](https://pub.dev/packages/flutter_bloc)                      |
| Dependency Injection | [get_it](https://pub.dev/packages/get_it)                                 |
| Routing              | [go_router](https://pub.dev/packages/go_router)                           |
| Networking           | [dio](https://pub.dev/packages/dio)                                        |
| Error Handling       | [fpdart](https://pub.dev/packages/fpdart) (`Either<Failure, T>`)          |
| Adaptive UI          | [adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui)     |
| Fonts                | [google_fonts](https://pub.dev/packages/google_fonts)                     |
| Secure Storage       | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| Linting              | [netglade_analysis](https://pub.dev/packages/netglade_analysis)           |

---

## Project Structure

```
lib/
├── core/
│   ├── di/                          # Dependency Injection
│   │   └── service_locator.dart     # GetIt service locator setup
│   ├── errors/                      # Error handling
│   │   ├── exceptions.dart          # Data-layer exceptions
│   │   └── failures.dart            # Domain-layer failures (Equatable)
│   ├── network/                     # Network layer
│   │   └── network_client.dart      # Dio HTTP client configuration
│   ├── shared/                      # Shared utilities
│   │   └── contants.dart            # App-wide constants (base URLs, etc.)
│   └── usecase/                     # Base use case contract
│       └── usecase.dart             # UseCase<T, Params> abstract class
│
├── features/                        # Feature modules (Clean Architecture)
│   ├── app/                         # App-level configuration
│   │   ├── app.dart                 # MainApp widget + MultiBlocProvider
│   │   ├── routes.dart              # GoRouter route definitions
│   │   └── themes.dart              # Material & Cupertino themes
│   ├── auth/                        # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/         # Remote/local data sources
│   │   │   ├── models/              # DTOs with fromJson/toJson
│   │   │   └── repositories/        # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/            # Pure business objects
│   │   │   ├── repositories/        # Abstract repository contracts
│   │   │   └── usecases/            # Business rule use cases
│   │   └── presentation/
│   │       ├── bloc/                # Bloc + Events + States
│   │       └── pages/               # UI pages
│   └── counter/                     # Example counter feature
│       └── counter_page.dart
│
└── main.dart                        # Entry point
```

---

## Clean Architecture

ChronoFlow follows Clean Architecture with three layers per feature:

### 1. Domain Layer (Business Logic)

- **Entities** — Pure Dart classes with `Equatable`
- **Use Cases** — Single-responsibility business rules implementing `UseCase<T, Params>`
- **Repository Interfaces** — Abstract contracts returning `Either<Failure, T>`

### 2. Data Layer (Data Sources)

- **Models** — DTOs that extend domain entities, include `fromJson` factories
- **Data Sources** — API clients using Dio, throw exceptions on error
- **Repository Implementations** — Implement domain interfaces, convert exceptions to failures

### 3. Presentation Layer (UI + State)

- **Bloc** — Events, States, and Bloc classes using `flutter_bloc`
- **Pages** — Adaptive UI using `adaptive_platform_ui` widgets
- **Widgets** — Reusable composable components

### Dependency Rule

```
Presentation → Domain ← Data
```

- Domain layer has **zero** dependencies on other layers
- Presentation depends on Domain (entities, use cases)
- Data depends on Domain (implements repository interfaces)
- Dependency injection via `get_it` wires everything together

---

## Getting Started

### Prerequisites

- Flutter SDK (latest stable, >= 3.38.9)
- Dart SDK (>= 3.10.3, comes with Flutter)
- Git
- An IDE (VS Code or Android Studio)

### Setup

```bash
git clone https://github.com/your-username/chronoflow.git
cd chronoflow
flutter pub get
flutter run
```

---

## Architecture Guidelines

### Naming Conventions

| Type                     | Pattern                              | Example                             |
| ------------------------ | ------------------------------------ | ----------------------------------- |
| Entities                 | Domain class name                    | `User`, `Role`, `Permission`        |
| Models                   | `*Model`                             | `UserModel`, `LoginRequestModel`    |
| Use Cases                | `*UseCase`                           | `LoginUseCase`, `LogoutUseCase`     |
| Repositories (interface) | `*Repository`                        | `AuthRepository`                    |
| Repositories (impl)      | `*RepositoryImpl`                    | `AuthRepositoryImpl`                |
| Data Sources (interface) | `*DataSource`                        | `AuthRemoteDataSource`              |
| Data Sources (impl)      | `*DataSourceImpl`                    | `AuthRemoteDataSourceImpl`          |
| Blocs                    | `*Bloc`                              | `AuthBloc`                          |
| Events                   | Verb + `Requested/Started/Completed` | `LoginRequested`, `LogoutRequested` |
| States                   | Noun + State description             | `AuthLoading`, `AuthAuthenticated`  |
| Pages                    | `*Page`                              | `LoginPage`, `HomePage`             |

### State Management Best Practices

- Use `Bloc` for complex state management
- Use `Cubit` for simpler state (optional)
- Always extend `Equatable` for events and states
- Use `BlocBuilder` for rebuilding UI based on state
- Use `BlocListener` for side effects (navigation, snackbars)
- Use `BlocConsumer` when you need both builder and listener

### Error Handling Flow

```
DataSource (throws Exception) → Repository (catches, returns Either<Failure, T>) → UseCase (passes through) → Bloc (folds result)
```

---

## Testing

```
test/
├── features/
│   └── auth/
│       ├── data/
│       │   ├── models/
│       │   ├── datasources/
│       │   └── repositories/
│       ├── domain/
│       │   └── usecases/
│       └── presentation/
│           └── bloc/
└── core/
```

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run a specific test file
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

---

## Contributing

Want to add a new feature or fix a bug? Check out our [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Complete login implementation walkthrough using Bloc + Clean Architecture
- Step-by-step guide for DI registration, routing, and MultiBlocProvider
- Code standards and naming conventions
- Testing requirements with examples
- Pull request process

---

## License

[![Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)

This project is released into the public domain. See [LICENSE](LICENSE) for details.

---

**Built with Flutter**
