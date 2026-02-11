# Contributing to ChronoFlow

Thank you for your interest in contributing to ChronoFlow! This guide will help you understand our development workflow and standards.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Clean Architecture Guidelines](#clean-architecture-guidelines)
- [How to Add a New Feature](#how-to-add-a-new-feature)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)

---

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Git
- An IDE (VS Code, Android Studio, or IntelliJ)

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

- `feature/` - New features (e.g., `feature/login`)
- `fix/` - Bug fixes (e.g., `fix/login-validation`)
- `refactor/` - Code refactoring (e.g., `refactor/auth-flow`)
- `docs/` - Documentation updates (e.g., `docs/api-guide`)

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

- `feat:` - New features
- `fix:` - Bug fixes
- `refactor:` - Code refactoring
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

---

## Clean Architecture Guidelines

### Layer Responsibilities

#### **1. Domain Layer** (Business Logic)

**Location:** `lib/features/{feature}/domain/`

- **Entities** (`entities/`): Pure business objects
  - No external dependencies
  - Use `Equatable` for value equality
  - Immutable classes
- **Repository Interfaces** (`repositories/`): Abstract contracts
  - Define what data operations are needed
  - Return `Either<Failure, T>` for error handling
- **Use Cases** (`usecases/`): Business rules
  - Single responsibility (one use case = one action)
  - Depend only on repository interfaces
  - Implement `UseCase<Type, Params>` base class

#### **2. Data Layer** (Data Sources)

**Location:** `lib/features/{feature}/data/`

- **Models** (`models/`): Data transfer objects
  - Extend domain entities
  - Include JSON serialization
  - Manual toJson/fromJson (no code generation)
- **Data Sources** (`datasources/`): API clients, local storage
  - Throw exceptions (not failures)
  - Interface + Implementation pattern
- **Repository Implementations** (`repositories/`): Concrete implementations
  - Implement domain repository interfaces
  - Convert exceptions to failures
  - Handle data source coordination

#### **3. Presentation Layer** (UI + State)

**Location:** `lib/features/{feature}/presentation/`

- **Bloc** (`bloc/`): State management with flutter_bloc
  - Events, States, and Bloc classes
  - Use `Equatable` for all events and states
  - Handle business logic coordination
- **Pages** (`pages/`): Page-level UI
  - Use `BlocBuilder` for state-based UI
  - Use `BlocListener` for side effects
  - Use `BlocConsumer` when you need both
- **Widgets** (`widgets/`): Reusable components
  - Keep widgets focused and composable
  - Extract common UI patterns

### Dependency Rule

**Critical:** Dependencies must point inward only!

```
Presentation → Domain ← Data
```

- Presentation depends on Domain (uses entities, use cases)
- Data depends on Domain (implements repositories, converts to entities)
- Domain depends on NOTHING (pure business logic)

---

## How to Add a New Feature

Let's walk through creating a complete **Login** feature following Clean Architecture with **Bloc**.

### API Reference

**Endpoint:** `/users/auth/login`

**Request:**

```json
POST /api/login
Content-Type: application/json

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

### Response

**Success (200 OK):**

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

| Field                      | Type    | Description                            |
| -------------------------- | ------- | -------------------------------------- |
| `code`                     | integer | HTTP status code (200, 401, 500, etc.) |
| `data.user`                | object  | Authenticated user profile             |
| `data.user.id`             | string  | Unique user identifier                 |
| `data.roles`               | array   | List of roles assigned to user         |
| `data.roles[].permissions` | array   | Permission objects within each role    |
| `msg`                      | string  | Human-readable status message          |

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

---

### Step 2: Create Domain Entities

**`domain/entities/permission.dart`**

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

**`domain/entities/role.dart`**

```dart
import 'package:equatable/equatable.dart';
import 'permission.dart';

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

**`domain/entities/user.dart`**

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

**`domain/entities/auth_result.dart`**

```dart
import 'package:equatable/equatable.dart';
import 'user.dart';
import 'role.dart';

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

---

### Step 3: Create Repository Interface

**`domain/repositories/auth_repository.dart`**

```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login({
    required String username,
    required String password,
    required bool remember,
  });

  Future<Either<Failure, void>> logout();
}
```

---

### Step 4: Create Use Cases

**`domain/usecases/login_usecase.dart`**

```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

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

**`domain/usecases/logout_usecase.dart`**

```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
```

---

### Step 5: Create Data Models

**`data/models/permission_model.dart`**

```dart
import '../../domain/entities/permission.dart';

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

**`data/models/role_model.dart`**

```dart
import '../../domain/entities/role.dart';
import 'permission_model.dart';

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

**`data/models/user_model.dart`**

```dart
import '../../domain/entities/user.dart';

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

**`data/models/login_request_model.dart`**

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

**`data/models/login_response_model.dart`**

```dart
import '../../domain/entities/auth_result.dart';
import 'user_model.dart';
import 'role_model.dart';

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

---

### Step 6: Create Remote Data Source

**`data/datasources/auth_remote_datasource.dart`**

```dart
import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

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
      final response = await dio.post(
        '/users/auth/login',
        data: request.toJson(),
      );

      final loginResponse = LoginResponseModel.fromJson(response.data);

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
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      } else if (e.response?.statusCode == 401) {
        throw ServerException(message: 'Invalid credentials');
      } else if (e.response?.statusCode == 500) {
        throw ServerException(message: 'Server error');
      } else {
        throw ServerException(
          message: e.response?.data['msg'] ?? 'Unknown error occurred',
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/users/auth/logout');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['msg'] ?? 'Logout failed',
      );
    }
  }
}
```

---

### Step 7: Implement Repository

**`data/repositories/auth_repository_impl.dart`**

```dart
import 'package:fpdart/fpdart.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AuthResult>> login({
    required String username,
    required String password,
    required bool remember,
  }) async {
    try {
      final request = LoginRequestModel(
        username: username,
        password: password,
        remember: remember,
      );

      final response = await remoteDataSource.login(request);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }
}
```

---

### Step 8: Create Bloc Events

**`presentation/bloc/auth_event.dart`**

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

---

### Step 9: Create Bloc States

**`presentation/bloc/auth_state.dart`**

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_result.dart';

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

---

### Step 10: Create Bloc

**`presentation/bloc/auth_bloc.dart`**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecase/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

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

---

### Step 11: Create Login Page

**`presentation/pages/login_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.event,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ChronoFlow',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Event Management Platform',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Username Field
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
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
                        return TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
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
                        return Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: state is AuthLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                            ),
                            const Text('Remember me'),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return TextButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  context.push('/forgot-password');
                                },
                          child: const Text('Forgot Password?'),
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

---

## Code Standards

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
- Use `analysis_options.yaml` for linting (netglade_analysis)
- Maximum line length: 80 characters
- Always use trailing commas for better formatting
- Prefer `const` constructors when possible

### State Management with Bloc

```dart
// ✅ Good: Use Equatable for events and states
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  const LoginRequested(this.username);
  @override
  List<Object?> get props => [username];
}

// ✅ Good: Use BlocBuilder for UI updates
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    return LoginButton();
  },
)

// ✅ Good: Use BlocListener for side effects
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: MyWidget(),
)
```

### Error Handling

```dart
// ✅ Good: Use Either for error handling in domain/data layers
Future<Either<Failure, User>> login({
  required String username,
  required String password,
});

// ✅ Good: Throw exceptions in data sources
Future<LoginResponseModel> login(LoginRequestModel request) async {
  try {
    final response = await dio.post('/login', data: request.toJson());
    return LoginResponseModel.fromJson(response.data);
  } on DioException catch (e) {
    throw ServerException(message: e.message ?? 'Server error');
  }
}

// ✅ Good: Convert exceptions to failures in repositories
Future<Either<Failure, User>> login(...) async {
  try {
    final response = await remoteDataSource.login(request);
    return Right(response.toEntity());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } on NetworkException {
    return Left(NetworkFailure());
  }
}
```

### File Organization

```dart
// ✅ Good: Organize imports
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// 4. Relative imports
import '../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
```

---

## Testing Requirements

### Test Coverage

All new features must include tests:

- **Unit Tests**: Use cases, repositories, data sources
- **Bloc Tests**: Test events and state transitions
- **Widget Tests**: Pages and widgets

### Test Structure

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

### Example Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const tUsername = 'test';
    const tPassword = 'pass123';
    const tUser = User(
      id: '1',
      name: 'Test',
      email: 'test@example.com',
      role: 'USER',
    );
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
        LoginParams(username: tUsername, password: tPassword),
      );

      // Assert
      expect(result, const Right(tAuthResult));
      verify(() => mockRepository.login(
            username: tUsername,
            password: tPassword,
            remember: false,
          )).called(1);
    });
  });
}
```

### Example Bloc Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
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
}
```

---

## Pull Request Process

### Before Submitting

1. **Linting**: Ensure no lint errors

   ```bash
   flutter analyze
   ```

2. **Testing**: All tests must pass

   ```bash
   flutter test
   ```

3. **Format Code**: Format all files
   ```bash
   dart format .
   ```

### Pull Request Template

```markdown
## escription

Brief description of what this PR does.

## ype of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## elated Issue

Closes #(issue number)

## hanges Made

- Change 1
- Change 2

## esting

- [ ] Unit tests added/updated
- [ ] Bloc tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## hecklist

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
- [Flutter Testing Guide](https://flutter.dev/docs/testing)

---

**Thank you for contributing to ChronoFlow! 🎉**
