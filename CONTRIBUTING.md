# Contributing to ChronoFlow

Thank you for your interest in contributing to ChronoFlow! This guide will help you understand our development workflow and standards. It includes a **complete walkthrough** of adding a feature from scratch so you can see exactly how every piece fits together.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Clean Architecture Guidelines](#clean-architecture-guidelines)
- [How to Add a New Feature (Full Walkthrough)](#how-to-add-a-new-feature-full-walkthrough)
  - [Step 1: Create Feature Directory Structure](#step-1-create-feature-directory-structure)
  - [Step 2: Domain — Entities](#step-2-domain--entities)
  - [Step 3: Domain — Repository Interface](#step-3-domain--repository-interface)
  - [Step 4: Domain — Use Cases](#step-4-domain--use-cases)
  - [Step 5: Data — Models](#step-5-data--models)
  - [Step 6: Data — Remote Data Source](#step-6-data--remote-data-source)
  - [Step 7: Data — Repository Implementation](#step-7-data--repository-implementation)
  - [Step 8: Presentation — Bloc Events](#step-8-presentation--bloc-events)
  - [Step 9: Presentation — Bloc States](#step-9-presentation--bloc-states)
  - [Step 10: Presentation — Bloc](#step-10-presentation--bloc)
  - [Step 11: Presentation — Page (UI)](#step-11-presentation--page-ui)
  - [Step 12: Register in Dependency Injection](#step-12-register-in-dependency-injection)
  - [Step 13: Add Route to GoRouter](#step-13-add-route-to-gorouter)
  - [Step 14: Add Bloc to MultiBlocProvider](#step-14-add-bloc-to-multiblocprovider)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)

---

## Getting Started

### Prerequisites

- Flutter SDK (latest stable, >= 3.38.9)
- Dart SDK (>= 3.10.3, comes with Flutter)
- Git
- An IDE (VS Code or Android Studio)

### Initial Setup

1. **Fork and clone the repository**

   ```bash
   git clone https://github.com/your-username/chronoflow.git
   cd chronoflow
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Verify the setup**

   ```bash
   flutter test
   flutter run
   ```

---

## Development Workflow

### 1. Create a Feature Branch

Always create a new branch for your work:

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:

- `feature/` — New features (e.g., `feature/login`)
- `fix/` — Bug fixes (e.g., `fix/login-validation`)
- `refactor/` — Code refactoring (e.g., `refactor/auth-flow`)
- `docs/` — Documentation updates (e.g., `docs/api-guide`)

### 2. Make Your Changes

Follow the [Clean Architecture Guidelines](#clean-architecture-guidelines) and [Code Standards](#code-standards).

### 3. Test Your Changes

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

### 4. Commit Your Changes

Use conventional commit messages:

```bash
git add .
git commit -m "feat: add login functionality"
```

Commit message format:

- `feat:` — New features
- `fix:` — Bug fixes
- `refactor:` — Code refactoring
- `docs:` — Documentation changes
- `test:` — Adding or updating tests
- `chore:` — Maintenance tasks

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

---

## Clean Architecture Guidelines

### Layer Responsibilities

#### 1. Domain Layer (Business Logic)

**Location:** `lib/features/{feature}/domain/`

- **Entities** (`entities/`) — Pure business objects
  - No external dependencies
  - Use `Equatable` for value equality
  - Immutable classes with `const` constructors
- **Repository Interfaces** (`repositories/`) — Abstract contracts
  - Define what data operations are needed
  - Return `Either<Failure, T>` using `fpdart`
- **Use Cases** (`usecases/`) — Business rules
  - Single responsibility (one use case = one action)
  - Depend only on repository interfaces
  - Implement `UseCase<Type, Params>` base class

#### 2. Data Layer (Data Sources)

**Location:** `lib/features/{feature}/data/`

- **Models** (`models/`) — Data transfer objects
  - Extend domain entities (e.g., `UserModel extends User`)
  - Include `fromJson` factory constructors
  - Request models include `toJson` methods
  - Manual serialization (no code generation)
- **Data Sources** (`datasources/`) — API clients, local storage
  - Throw exceptions (not failures) — e.g., `ServerException`, `NetworkException`
  - Abstract interface + concrete implementation pattern
- **Repository Implementations** (`repositories/`) — Concrete implementations
  - Implement domain repository interfaces
  - Convert exceptions to failures using `_handleExceptions` helper
  - Return `Either<Failure, T>`

#### 3. Presentation Layer (UI + State)

**Location:** `lib/features/{feature}/presentation/`

- **Bloc** (`bloc/`) — State management with `flutter_bloc`
  - Events, States, and Bloc classes in separate files
  - Use `Equatable` for all events and states
  - Handle business logic coordination via use cases
- **Pages** (`pages/`) — Page-level UI
  - Use `BlocBuilder` for state-based UI
  - Use `BlocListener` for side effects (navigation, snackbars)
  - Use adaptive widgets from `adaptive_platform_ui`
- **Widgets** (`widgets/`) — Reusable components
  - Keep widgets focused and composable

### Dependency Rule

**Critical:** Dependencies must point inward only!

```
Presentation → Domain ← Data
```

- Presentation depends on Domain (uses entities, use cases)
- Data depends on Domain (implements repositories, converts to entities)
- Domain depends on **NOTHING** (pure business logic)

---

## How to Add a New Feature (Full Walkthrough)

This walkthrough creates a complete **Login** feature following Clean Architecture with Bloc. Follow these steps in order.

### API Reference

**Endpoint:** `POST /users/auth/login`

**Request:**

```json
{
  "username": "string",
  "password": "string",
  "remember": true
}
```

| Field      | Type    | Required | Description                              |
| ---------- | ------- | -------- | ---------------------------------------- |
| `username` | string  | Yes      | User login name                          |
| `password` | string  | Yes      | User password (sent over HTTPS)          |
| `remember` | boolean | No       | Keep session persistent (default: false) |

**Success Response (200 OK):**

```json
{
  "code": 200,
  "data": {
    "user": {
      "id": "u123",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "admin"
    },
    "roles": [
      {
        "id": "r1",
        "name": "Administrator",
        "key": "admin",
        "isDefault": true,
        "permissions": [
          {
            "id": "p1",
            "name": "Read Users",
            "key": "users:read",
            "description": null
          }
        ]
      }
    ]
  },
  "msg": "Login successful"
}
```

---

### Step 1: Create Feature Directory Structure

```bash
mkdir -p lib/features/auth/data/datasources
mkdir -p lib/features/auth/data/models
mkdir -p lib/features/auth/data/repositories
mkdir -p lib/features/auth/domain/entities
mkdir -p lib/features/auth/domain/repositories
mkdir -p lib/features/auth/domain/usecases
mkdir -p lib/features/auth/presentation/bloc
mkdir -p lib/features/auth/presentation/pages
```

Your feature folder should look like this:

```
lib/features/auth/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    └── pages/
```

---

### Step 2: Domain — Entities

Entities are pure business objects. They have no dependencies on Flutter, Dio, or any external package — only `equatable` for value equality.

**`lib/features/auth/domain/entities/permission.dart`**

```dart
import 'package:equatable/equatable.dart';

class Permission extends Equatable {
  final String id;
  final String name;
  final String key;
  final String? description;

  const Permission({
    required this.id,
    required this.name,
    required this.key,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, key, description];
}
```

**`lib/features/auth/domain/entities/role.dart`**

```dart
import 'package:chronoflow/features/auth/domain/entities/permission.dart';
import 'package:equatable/equatable.dart';

class Role extends Equatable {
  final String id;
  final String name;
  final String key;
  final bool isDefault;
  final List<Permission> permissions;

  const Role({
    required this.id,
    required this.name,
    required this.key,
    required this.isDefault,
    required this.permissions,
  });

  @override
  List<Object?> get props => [id, name, key, isDefault, permissions];
}
```

**`lib/features/auth/domain/entities/user.dart`**

```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, email, role];
}
```

**`lib/features/auth/domain/entities/auth_result.dart`**

```dart
import 'package:chronoflow/features/auth/domain/entities/role.dart';
import 'package:chronoflow/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class AuthResult extends Equatable {
  final User user;
  final List<Role> roles;

  const AuthResult({
    required this.user,
    required this.roles,
  });

  @override
  List<Object?> get props => [user, roles];
}
```

> **Key points for entities:**
>
> - Always use `const` constructors
> - Always extend `Equatable` and implement `props`
> - Use `package:chronoflow/...` imports (not relative)
> - No `fromJson`, `toJson`, or any serialization — that belongs in the Data layer

---

### Step 3: Domain — Repository Interface

The repository interface defines **what** data operations exist, without caring **how** they work.

**`lib/features/auth/domain/repositories/auth_repository.dart`**

```dart
import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login({
    required String username,
    required String password,
    required bool remember,
  });

  Future<Either<Failure, Unit>> logout();
}
```

> **Key points:**
>
> - Always return `Either<Failure, T>` — left side is the error, right side is success
> - Import `Failure` from `package:chronoflow/core/errors/failures.dart`
> - This is an `abstract class` — the Data layer will implement it

---

### Step 4: Domain — Use Cases

Each use case represents a **single action** the user can perform. They implement the base `UseCase<T, Params>` contract.

Here's the base class for reference (`lib/core/usecase/usecase.dart`):

```dart
import 'package:chronoflow/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {}
```

**`lib/features/auth/domain/usecases/login_usecase.dart`**

```dart
import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/core/usecase/usecase.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';
import 'package:chronoflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LoginUseCase implements UseCase<AuthResult, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(LoginParams params) async {
    return await repository.login(
      username: params.username,
      password: params.password,
      remember: params.remember,
    );
  }
}

class LoginParams {
  final String username;
  final String password;
  final bool remember;

  LoginParams({
    required this.username,
    required this.password,
    this.remember = false,
  });
}
```

**`lib/features/auth/domain/usecases/logout_usecase.dart`**

```dart
import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/core/usecase/usecase.dart';
import 'package:chronoflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LogoutUseCase implements UseCase<Unit, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return repository.logout();
  }
}
```

> **Key points:**
>
> - Use cases accept params via a dedicated params class (e.g., `LoginParams`)
> - For use cases with no input, use `NoParams`
> - The use case only calls the repository — no direct API/DB access

---

### Step 5: Data — Models

Models live in the Data layer. They **extend** domain entities and add serialization.

**`lib/features/auth/data/models/permission_model.dart`**

```dart
import 'package:chronoflow/features/auth/domain/entities/permission.dart';

class PermissionModel extends Permission {
  const PermissionModel({
    required super.id,
    required super.name,
    required super.key,
    super.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      description: json['description'] as String?,
    );
  }
}
```

**`lib/features/auth/data/models/role_model.dart`**

```dart
import 'package:chronoflow/features/auth/data/models/permission_model.dart';
import 'package:chronoflow/features/auth/domain/entities/role.dart';

class RoleModel extends Role {
  const RoleModel({
    required super.id,
    required super.name,
    required super.key,
    required super.isDefault,
    required super.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      isDefault: json['isDefault'] as bool,
      permissions: (json['permissions'] as List)
          .map((p) => PermissionModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

**`lib/features/auth/data/models/user_model.dart`**

```dart
import 'package:chronoflow/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}
```

**`lib/features/auth/data/models/login_request_model.dart`**

```dart
class LoginRequestModel {
  final String username;
  final String password;
  final bool remember;

  LoginRequestModel({
    required this.username,
    required this.password,
    this.remember = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'remember': remember,
    };
  }
}
```

**`lib/features/auth/data/models/login_response_model.dart`**

```dart
import 'package:chronoflow/features/auth/data/models/role_model.dart';
import 'package:chronoflow/features/auth/data/models/user_model.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';

class LoginResponseModel {
  final int code;
  final LoginDataModel data;
  final String msg;

  LoginResponseModel({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      code: json['code'] as int,
      data: LoginDataModel.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String,
    );
  }

  AuthResult toEntity() => data.toEntity();
}

class LoginDataModel {
  final UserModel user;
  final List<RoleModel> roles;

  LoginDataModel({
    required this.user,
    required this.roles,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      roles: (json['roles'] as List)
          .map((r) => RoleModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  AuthResult toEntity() {
    return AuthResult(
      user: user,
      roles: roles,
    );
  }
}
```

> **Key points:**
>
> - Response models extend domain entities — so they can be returned as entities automatically
> - Request models (e.g., `LoginRequestModel`) don't extend anything — they're just DTOs with `toJson`
> - Response wrapper models (e.g., `LoginResponseModel`) have a `toEntity()` method
> - We do **manual** JSON serialization (no build_runner or code generation)

---

### Step 6: Data — Remote Data Source

The data source talks directly to the API using Dio. It **throws exceptions** on failure — never returns `Either`.

**`lib/features/auth/data/datasources/auth_remote_datasource.dart`**

```dart
import 'package:chronoflow/core/errors/exceptions.dart';
import 'package:chronoflow/features/auth/data/models/login_request_model.dart';
import 'package:chronoflow/features/auth/data/models/login_response_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/users/auth/login',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      final loginResponse = LoginResponseModel.fromJson(response.data!);

      if (loginResponse.code != 0) {
        throw ServerException(
          message: loginResponse.msg.isEmpty
              ? 'Login failed'
              : loginResponse.msg,
        );
      }

      return loginResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      } else if (e.response?.statusCode == 401) {
        throw const ServerException(message: 'Invalid credentials');
      } else if (e.response?.statusCode == 500) {
        throw const ServerException(message: 'Server error');
      } else {
        throw const ServerException(message: 'Unknown error occurred');
      }
    } on FormatException catch (e) {
      throw ServerException(message: 'Invalid JSON: $e');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post<void>('/users/auth/logout');
    } on DioException {
      throw const ServerException(message: 'Logout failed');
    }
  }
}
```

> **Key points:**
>
> - Use `dio.post<Map<String, dynamic>>` with a type parameter so Dio parses JSON automatically
> - Check `response.data == null` for safety
> - Use `const` constructors on exceptions where possible
> - Throw `ServerException` or `NetworkException` from `package:chronoflow/core/errors/exceptions.dart`
> - Abstract class + implementation class pattern (`AuthRemoteDataSource` + `AuthRemoteDataSourceImpl`)

---

### Step 7: Data — Repository Implementation

The repository catches exceptions thrown by the data source and converts them to `Failure` objects wrapped in `Either`.

**`lib/features/auth/data/repositories/auth_repository_impl.dart`**

```dart
import 'package:chronoflow/core/errors/exceptions.dart';
import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:chronoflow/features/auth/data/models/login_request_model.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';
import 'package:chronoflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  /// Helper method to wrap try/catch logic for all repository methods.
  /// Catches known exceptions and maps them to Failure types.
  Future<Either<Failure, T>> _handleExceptions<T>(
    Future<T> Function() action,
  ) async {
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on Object catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> login({
    required String username,
    required String password,
    required bool remember,
  }) async {
    return _handleExceptions(() async {
      final request = LoginRequestModel(
        username: username,
        password: password,
        remember: remember,
      );
      final response = await remoteDataSource.login(request);
      return response.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on Object catch (_) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }
}
```

> **Key points:**
>
> - Use the `_handleExceptions<T>` helper to reduce boilerplate — pass a closure that does the actual work
> - Catch `ServerException` → `ServerFailure`, `NetworkException` → `NetworkFailure`
> - The final `on Object catch` is a catch-all for anything unexpected
> - For void returns, use `fpdart`'s `Unit` type and `unit` value (not `void`)

---

### Step 8: Presentation — Bloc Events

Events represent **user actions** or **system triggers** that the Bloc responds to.

**`lib/features/auth/presentation/bloc/auth_event.dart`**

```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final bool remember;

  const LoginRequested({
    required this.username,
    required this.password,
    this.remember = false,
  });

  @override
  List<Object?> get props => [username, password, remember];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
```

> **Naming convention:** Events use the pattern `VerbRequested` (e.g., `LoginRequested`, `LogoutRequested`)

---

### Step 9: Presentation — Bloc States

States represent what the UI should display at any given moment.

**`lib/features/auth/presentation/bloc/auth_state.dart`**

```dart
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthResult authResult;

  const AuthAuthenticated(this.authResult);

  @override
  List<Object?> get props => [authResult];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
```

> **Key points:**
>
> - Every state extends `Equatable` — this is required for Bloc to detect state changes
> - Always provide `const` constructors
> - States that carry data (like `AuthAuthenticated`) include the data as fields and list them in `props`

---

### Step 10: Presentation — Bloc

The Bloc ties events to state transitions, delegating business logic to use cases.

**`lib/features/auth/presentation/bloc/auth_bloc.dart`**

```dart
import 'package:chronoflow/core/usecase/usecase.dart';
import 'package:chronoflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:chronoflow/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(
        username: event.username,
        password: event.password,
        remember: event.remember,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResult) => emit(AuthAuthenticated(authResult)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await logoutUseCase(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
```

> **Key points:**
>
> - The Bloc receives **use cases** via constructor injection — never repositories directly
> - Register event handlers in the constructor using `on<EventType>(_handler)`
> - Use `result.fold()` to handle `Either<Failure, T>` — left is failure, right is success
> - Initial state is `const AuthInitial()`

---

### Step 11: Presentation — Page (UI)

Pages use `BlocBuilder` for reactive UI and `BlocListener` for side effects. We use `adaptive_platform_ui` widgets for cross-platform look.

**`lib/features/auth/presentation/pages/login_page.dart`**

```dart
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          remember: _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: const AdaptiveAppBar(title: 'Login'),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            AdaptiveSnackBar.show(
              context,
              message: state.message,
              type: AdaptiveSnackBarType.error,
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.event, size: 80, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text('ChronoFlow', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text(
                      'Event Management Platform',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Username Field
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AdaptiveTextFormField(
                          controller: _usernameController,
                          placeholder: 'Username',
                          prefix: const Icon(Icons.person),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          enabled: state is! AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AdaptiveTextFormField(
                          controller: _passwordController,
                          placeholder: 'Password',
                          prefix: const Icon(Icons.lock),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          suffix: AdaptiveButton.icon(
                            icon: _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          enabled: state is! AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Remember Me
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AdaptiveListTile(
                          leading: AdaptiveSwitch(
                            value: _rememberMe,
                            onChanged: state is AuthLoading
                                ? null
                                : (value) =>
                                    setState(() => _rememberMe = value),
                          ),
                          title: const Text('Remember me'),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(
                            child: LinearProgressIndicator(),
                          );
                        }
                        return AdaptiveButton(
                          onPressed: _handleLogin,
                          label: 'Login',
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AdaptiveButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () => context.push('/forgot-password'),
                          label: 'Forgot Password?',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

> **Key points:**
>
> - Use `AdaptiveScaffold`, `AdaptiveAppBar`, `AdaptiveTextFormField`, `AdaptiveButton`, `AdaptiveSwitch`, `AdaptiveListTile`, `AdaptiveSnackBar` from `adaptive_platform_ui`
> - Use `BlocListener` for navigation and snackbars (side effects)
> - Use `BlocBuilder` for each widget that depends on bloc state
> - Use `context.read<AuthBloc>().add(...)` to dispatch events
> - Use `go_router`'s `context.go()` for navigation and `context.push()` for pushing routes

---

### Step 12: Register in Dependency Injection

This is where everything gets wired together. Open `lib/core/di/service_locator.dart` and register your new feature's dependencies **in the correct order**: Data Source → Repository → Use Cases → Bloc.

**`lib/core/di/service_locator.dart`**

```dart
import 'package:chronoflow/core/network/network_client.dart';
import 'package:chronoflow/core/shared/contants.dart';
import 'package:chronoflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:chronoflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chronoflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:chronoflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:chronoflow/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  serviceLocator
    // ===== Core =====
    ..registerFactory<Constant>(Constant.new)
    ..registerFactory<Dio>(
      () => NetworkClient(Dio(), constant: serviceLocator()).dio,
    )

    // ===== Auth Feature =====
    // 1. Data Sources (factory — new instance each time)
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
    )
    // 2. Repository (lazySingleton — same instance app-wide)
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )
    // 3. Use Cases (factory — lightweight, can recreate)
    ..registerFactory(() => LoginUseCase(serviceLocator()))
    ..registerFactory(() => LogoutUseCase(serviceLocator()))
    // 4. Bloc (factory — fresh instance for each screen)
    ..registerFactory(
      () => AuthBloc(
        loginUseCase: serviceLocator(),
        logoutUseCase: serviceLocator(),
      ),
    );
}
```

**How to add your new feature:**

Let's say you're adding an **Event** feature. You would add below the Auth section:

```dart
    // ===== Event Feature =====
    // 1. Data Sources
    ..registerFactory<EventRemoteDataSource>(
      () => EventRemoteDataSourceImpl(serviceLocator()),
    )
    // 2. Repository
    ..registerLazySingleton<EventRepository>(
      () => EventRepositoryImpl(serviceLocator()),
    )
    // 3. Use Cases
    ..registerFactory(() => GetEventsUseCase(serviceLocator()))
    ..registerFactory(() => CreateEventUseCase(serviceLocator()))
    // 4. Bloc
    ..registerFactory(
      () => EventBloc(
        getEventsUseCase: serviceLocator(),
        createEventUseCase: serviceLocator(),
      ),
    );
```

> **Registration types explained:**
>
> | Method                  | When to use                                                                                   |
> | ----------------------- | --------------------------------------------------------------------------------------------- |
> | `registerFactory`       | Creates a **new instance** every time it's requested. Use for Blocs, Use Cases, Data Sources. |
> | `registerLazySingleton` | Creates **one instance** on first request, reuses it forever. Use for Repositories.           |
> | `registerSingleton`     | Creates **one instance immediately** at registration time. Use sparingly.                     |
>
> **Why this order matters:** `serviceLocator()` resolves dependencies at call time. If you register a Bloc that needs a UseCase, the UseCase must be registered first (or at least before the Bloc is resolved). The cascade (`..`) syntax registers everything in order.

---

### Step 13: Add Route to GoRouter

Open `lib/features/app/routes.dart` and add a route for your new page.

**`lib/features/app/routes.dart`**

```dart
import 'package:chronoflow/features/auth/presentation/pages/login_page.dart';
import 'package:chronoflow/features/counter/counter_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  GoRouter generateRoute() => GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        name: 'counter',
        builder: (context, state) => const CounterPage(
          title: 'Counter Page',
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
```

**How to add a new route:**

```dart
import 'package:chronoflow/features/events/presentation/pages/events_page.dart';

// Inside the routes list, add:
GoRoute(
  path: '/events',
  name: 'events',
  builder: (context, state) => const EventsPage(),
),
```

**For nested routes** (e.g., event details):

```dart
GoRoute(
  path: '/events',
  name: 'events',
  builder: (context, state) => const EventsPage(),
  routes: [
    GoRoute(
      path: ':id',  // accessed as /events/123
      name: 'event-details',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EventDetailsPage(eventId: id);
      },
    ),
  ],
),
```

> **Navigation tips:**
>
> - `context.go('/events')` — Navigates and replaces the current stack
> - `context.push('/events')` — Pushes onto the navigation stack
> - `context.pop()` — Goes back
> - `context.goNamed('events')` — Navigate by route name

---

### Step 14: Add Bloc to MultiBlocProvider

Open `lib/features/app/app.dart` and register your Bloc in the `MultiBlocProvider` so it's available throughout the widget tree.

**`lib/features/app/app.dart`**

```dart
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:chronoflow/core/di/service_locator.dart';
import 'package:chronoflow/features/app/routes.dart';
import 'package:chronoflow/features/app/themes.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
      ],
      child: AdaptiveApp.router(
        title: 'ChronoFlow',
        themeMode: ThemeMode.system,
        materialLightTheme: AppThemes.materialLightTheme,
        materialDarkTheme: AppThemes.materialDarkTheme,
        cupertinoLightTheme: AppThemes.cupertinoLightTheme,
        cupertinoDarkTheme: AppThemes.cupertinoDarkTheme,
        routerConfig: AppRouter().generateRoute(),
      ),
    );
  }
}
```

**How to add your new Bloc:**

```dart
import 'package:chronoflow/features/events/presentation/bloc/event_bloc.dart';

// Inside the providers list, add:
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
    BlocProvider(create: (_) => serviceLocator<EventBloc>()), // <-- add here
  ],
  // ...
);
```

> **When to use MultiBlocProvider vs local BlocProvider:**
>
> | Approach                          | When to use                                                                         |
> | --------------------------------- | ----------------------------------------------------------------------------------- |
> | `MultiBlocProvider` in `app.dart` | Bloc is needed **across multiple pages** (e.g., AuthBloc for auth state everywhere) |
> | Local `BlocProvider` in a page    | Bloc is only needed **within one page** (e.g., a form-specific Bloc)                |
>
> **Local BlocProvider example** (if you don't need the Bloc app-wide):
>
> ```dart
> // In your page or route builder:
> BlocProvider(
>   create: (_) => serviceLocator<EventBloc>()..add(const LoadEvents()),
>   child: const EventsPage(),
> )
> ```
>
> The `..add(const LoadEvents())` immediately dispatches an event when the Bloc is created — useful for loading data on page open.

---

## Summary: New Feature Checklist

When adding a new feature, make sure you complete **all** of these steps:

- [ ] **Step 1** — Create directory structure under `lib/features/{feature}/`
- [ ] **Step 2** — Create domain entities with `Equatable`
- [ ] **Step 3** — Create repository interface returning `Either<Failure, T>`
- [ ] **Step 4** — Create use cases implementing `UseCase<T, Params>`
- [ ] **Step 5** — Create data models extending entities with `fromJson`/`toJson`
- [ ] **Step 6** — Create remote data source (abstract + implementation)
- [ ] **Step 7** — Create repository implementation with `_handleExceptions`
- [ ] **Step 8** — Create Bloc events with `Equatable`
- [ ] **Step 9** — Create Bloc states with `Equatable`
- [ ] **Step 10** — Create Bloc class with event handlers
- [ ] **Step 11** — Create page with `BlocBuilder`/`BlocListener`
- [ ] **Step 12** — Register in `service_locator.dart` (DI)
- [ ] **Step 13** — Add route in `routes.dart` (GoRouter)
- [ ] **Step 14** — Add Bloc to `MultiBlocProvider` in `app.dart` (if needed app-wide)
- [ ] **Tests** — Write unit tests for use cases, repository, bloc

---

## Code Standards

### Import Style

Always use **package imports** (not relative imports):

```dart
// CORRECT — package imports
import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/features/auth/domain/entities/user.dart';

// WRONG — relative imports
import '../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
```

### Import Ordering

Organize imports in this order, separated by blank lines:

```dart
// 1. Dart SDK imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. External package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// 4. Project imports
import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/features/auth/domain/entities/user.dart';
```

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

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Linting is enforced by `netglade_analysis` via `analysis_options.yaml`
- Always use trailing commas for better formatting
- Prefer `const` constructors when possible

### State Management Patterns

```dart
// BlocBuilder — rebuilds UI based on state
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return const LinearProgressIndicator();
    }
    return AdaptiveButton(onPressed: _handleLogin, label: 'Login');
  },
)

// BlocListener — side effects only (no UI rebuild)
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      AdaptiveSnackBar.show(context, message: state.message, type: AdaptiveSnackBarType.error);
    }
  },
  child: MyWidget(),
)

// BlocConsumer — both builder and listener in one
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) { /* side effects */ },
  builder: (context, state) { /* UI */ },
)
```

### Error Handling Patterns

```dart
// Data Source — throws exceptions
Future<LoginResponseModel> login(LoginRequestModel request) async {
  try {
    final response = await dio.post<Map<String, dynamic>>('/users/auth/login', data: request.toJson());
    return LoginResponseModel.fromJson(response.data!);
  } on DioException catch (e) {
    throw ServerException(message: e.message ?? 'Server error');
  }
}

// Repository — catches exceptions, returns Either<Failure, T>
Future<Either<Failure, T>> _handleExceptions<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(message: e.message));
  } on Object catch (e) {
    return Left(ServerFailure(message: 'Unexpected error: $e'));
  }
}

// Bloc — folds Either result
final result = await loginUseCase(params);
result.fold(
  (failure) => emit(AuthError(failure.message)),
  (data) => emit(AuthAuthenticated(data)),
);
```

---

## Testing Requirements

### Test Coverage

All new features must include tests:

- **Unit Tests** — Use cases, repositories, data sources
- **Bloc Tests** — Event/state transitions
- **Widget Tests** — Pages and widgets

### Test Structure

Mirror the feature structure under `test/`:

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

### Example: Use Case Test

```dart
import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';
import 'package:chronoflow/features/auth/domain/entities/user.dart';
import 'package:chronoflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:chronoflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const tUser = User(id: '1', name: 'Test', email: 'test@example.com', role: 'user');
    const tAuthResult = AuthResult(user: tUser, roles: []);

    test('should return AuthResult when login is successful', () async {
      // Arrange
      when(() => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
            remember: any(named: 'remember'),
          )).thenAnswer((_) async => const Right(tAuthResult));

      // Act
      final result = await useCase(
        LoginParams(username: 'test', password: 'pass123'),
      );

      // Assert
      expect(result, const Right(tAuthResult));
      verify(() => mockRepository.login(
            username: 'test',
            password: 'pass123',
            remember: false,
          )).called(1);
    });

    test('should return ServerFailure when login fails', () async {
      // Arrange
      when(() => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
            remember: any(named: 'remember'),
          )).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Invalid credentials')),
      );

      // Act
      final result = await useCase(
        LoginParams(username: 'test', password: 'wrong'),
      );

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

### Example: Bloc Test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/core/usecase/usecase.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';
import 'package:chronoflow/features/auth/domain/entities/user.dart';
import 'package:chronoflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:chronoflow/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  const tUser = User(id: '1', name: 'Test', email: 'test@example.com', role: 'user');
  const tAuthResult = AuthResult(user: tUser, roles: []);

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    bloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when login succeeds',
    build: () {
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => const Right(tAuthResult));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const LoginRequested(username: 'test', password: 'pass'),
    ),
    expect: () => [
      const AuthLoading(),
      const AuthAuthenticated(tAuthResult),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when login fails',
    build: () {
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => Left(ServerFailure(message: 'Invalid credentials')));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const LoginRequested(username: 'test', password: 'wrong'),
    ),
    expect: () => [
      const AuthLoading(),
      const AuthError('Invalid credentials'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthUnauthenticated] when logout succeeds',
    build: () {
        when(() => mockLogoutUseCase(any()))
          .thenAnswer((_) async => const Right(unit));
      return bloc;
    },
    act: (bloc) => bloc.add(const LogoutRequested()),
    expect: () => [const AuthUnauthenticated()],
  );
}
```

---

## Pull Request Process

### Before Submitting

1. **Linting** — Ensure no lint errors:

   ```bash
   flutter analyze
   ```

2. **Testing** — All tests must pass:

   ```bash
   flutter test
   ```

3. **Format Code** — Format all files:

   ```bash
   dart format .
   ```

### Pull Request Template

```markdown
## Description

Brief description of what this PR does.

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issue

Closes #(issue number)

## Changes Made

- Change 1
- Change 2

## Testing

- [ ] Unit tests added/updated
- [ ] Bloc tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## Checklist

- [ ] Code follows project style guidelines
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No lint errors
```

### Review Process

1. At least one maintainer must approve
2. All CI checks must pass
3. No merge conflicts
4. Code follows architecture guidelines

---

## Additional Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Bloc Documentation](https://bloclibrary.dev/)
- [fpdart Package](https://pub.dev/packages/fpdart)
- [get_it Package](https://pub.dev/packages/get_it)
- [go_router Package](https://pub.dev/packages/go_router)
- [adaptive_platform_ui Package](https://pub.dev/packages/adaptive_platform_ui)
- [Flutter Testing Guide](https://flutter.dev/docs/testing)

---

**Thank you for contributing to ChronoFlow!**
