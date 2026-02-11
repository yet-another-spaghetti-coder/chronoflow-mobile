# ChronoFlow

**ChronoFlow** is an Event Management platform.

---

## Project Structure

```
lib/
├── core/
│   ├── di/                          # Dependency Injection
│   │   └── service_locator.dart     # Service locator setup
│   ├── network/                     # Network layer
│   │   └── network_client.dart      # HTTP client configuration
│   └── shared/                      # Shared utilities
│       └── constants.dart           # App-wide constants
│
├── features/                        # Feature modules
│   └── app/                         # App-level features
│       ├── app.dart                 # Main app widget
│       ├── routes.dart              # App routing
│       └── themes.dart              # App theming
│
└── main.dart                        # Application entry point
```

---

## Clean Architecture Structure

ChronoFlow follows Clean Architecture with the following layers:

### **1. Presentation Layer** (UI + State Management)

- **Pages**: UI components
- **Blocs**: Business logic and state using flutter_bloc
- **Widgets**: Reusable UI components

### **2. Domain Layer** (Business Logic)

- **Entities**: Core business models
- **Use Cases**: Business rules and operations
- **Repository Interfaces**: Abstract contracts

### **3. Data Layer** (Data Sources)

- **Models**: Data transfer objects (DTOs)
- **Repository Implementations**: Concrete implementations
- **Data Sources**: API clients, local storage

---

## Contributing

Want to add a new feature or fix a bug? Check out our [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Complete login implementation example using Bloc
- Clean Architecture best practices
- Code standards and naming conventions
- Testing requirements with examples
- Pull request process

---

## Architecture Guidelines

### **Dependency Rule**

- Dependencies point inward: Presentation → Domain ← Data
- Domain layer has no dependencies on other layers
- Use dependency injection (Riverpod providers)

### **Naming Conventions**

- **Entities**: `*Entity` or domain class name (e.g., `User`, `Event`)
- **Models**: `*Model` (e.g., `UserModel`, `LoginRequestModel`)
- **Use Cases**: `*UseCase` (e.g., `LoginUseCase`)
- **Repositories**: `*Repository` (interface), `*RepositoryImpl` (implementation)
- **Blocs**: `*Bloc` (e.g., `AuthBloc`, `EventBloc`)
- **Events**: `*Event` with specific event classes (e.g., `LoginRequested`)
- **States**: `*State` with specific state classes (e.g., `AuthLoading`)
- **Pages**: `*Page` (e.g., `LoginPage`, `EventDetailsPage`)

### **State Management Best Practices**

- Use `Bloc` for complex state management
- Use `Cubit` for simpler state (optional)
- Always extend `Equatable` for events and states
- Use `BlocBuilder` for rebuilding UI based on state
- Use `BlocListener` for side effects (navigation, snackbars)
- Use `BlocConsumer` when you need both builder and listener

---

## Testing

```
test/
├── features/
│   └── auth/
│       ├── data/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   └── usecases/
│       └── presentation/
│           └── providers/
└── core/
```

---

## Additional Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Bloc Documentation](https://bloclibrary.dev/)
- [Flutter Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
- [CONTRIBUTING.md](CONTRIBUTING.md) - Complete guide with login implementation example

---

## License

[![Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)

This project is released into the public domain. See [LICENSE](LICENSE) for details.

---

**Built using Flutter**
