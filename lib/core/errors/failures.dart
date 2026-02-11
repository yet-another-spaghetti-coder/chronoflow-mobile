import 'package:chronoflow/core/errors/exceptions.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final Map<String, dynamic>? metadata;

  const Failure({
    required this.message,
    this.code,
    this.metadata,
  });

  @override
  List<Object?> get props => [message, code, metadata];

  @override
  String toString() => '[$runtimeType] $message${code != null ? ' ($code)' : ''}';
}

// ==================== NETWORK FAILURES ====================

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  }) : super(code: 'NETWORK_FAILURE');
}

class TimeoutFailure extends Failure {
  final Duration? duration;

  TimeoutFailure({
    this.duration,
    super.message = 'The operation timed out. Please try again.',
  }) : super(
         code: 'TIMEOUT',
         metadata: duration != null ? {'duration': duration.inSeconds} : null,
       );

  @override
  List<Object?> get props => [message, code, metadata, duration];
}

class ServerFailure extends Failure {
  final int? statusCode;

  ServerFailure({
    required super.message,
    this.statusCode,
  }) : super(
         code: 'SERVER_ERROR',
         metadata: statusCode != null ? {'statusCode': statusCode} : null,
       );

  factory ServerFailure.fromException(ServerException e) {
    return ServerFailure(
      message: e.message,
      statusCode: e.statusCode,
    );
  }

  @override
  List<Object?> get props => [message, code, metadata, statusCode];
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({
    super.message = 'Failed to connect to server',
  }) : super(code: 'CONNECTION_FAILURE');
}

// ==================== AUTHENTICATION/AUTHORIZATION ====================

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    String? code,
    super.metadata,
  }) : super(code: code ?? 'AUTH_FAILURE');
}

class UnauthorizedFailure extends AuthFailure {
  const UnauthorizedFailure({
    super.message = 'Please log in to continue',
  }) : super(code: 'UNAUTHORIZED');
}

class ForbiddenFailure extends AuthFailure {
  const ForbiddenFailure({
    super.message = 'You do not have permission to perform this action',
  }) : super(code: 'FORBIDDEN');
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure({
    super.message = 'Your session has expired. Please log in again.',
  }) : super(code: 'SESSION_EXPIRED');
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure({
    super.message = 'Invalid email or password',
  }) : super(code: 'INVALID_CREDENTIALS');
}

class AccountLockedFailure extends AuthFailure {
  final DateTime? unlockTime;

  AccountLockedFailure({
    super.message = 'Account is temporarily locked',
    this.unlockTime,
  }) : super(
         code: 'ACCOUNT_LOCKED',
         metadata: unlockTime != null ? {'unlockTime': unlockTime.toIso8601String()} : null,
       );

  @override
  List<Object?> get props => [message, code, metadata, unlockTime];
}

class TokenRefreshFailure extends AuthFailure {
  const TokenRefreshFailure({
    super.message = 'Failed to refresh authentication token',
  }) : super(code: 'TOKEN_REFRESH_FAILED');
}

// ==================== VALIDATION/INPUT FAILURES ====================

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  }) : super(code: 'VALIDATION_FAILURE');

  factory ValidationFailure.single(String field, String error) {
    return ValidationFailure(
      message: 'Validation failed',
      fieldErrors: {
        field: [error],
      },
    );
  }

  List<String>? getFieldErrors(String field) => fieldErrors?[field];

  bool hasFieldErrors() => fieldErrors?.isNotEmpty ?? false;

  @override
  List<Object?> get props => [message, code, metadata, fieldErrors];
}

class InvalidInputFailure extends Failure {
  final String? field;
  final dynamic value;

  InvalidInputFailure({
    required super.message,
    this.field,
    this.value,
  }) : super(
         code: 'INVALID_INPUT',
         metadata: field != null ? {'field': field, 'value': value} : null,
       );

  @override
  List<Object?> get props => [message, code, metadata, field, value];
}

class MissingRequiredFieldFailure extends ValidationFailure {
  final List<String> missingFields;

  MissingRequiredFieldFailure({
    required this.missingFields,
    super.message = 'Required fields are missing',
  }) : super(
         fieldErrors: {
           for (var f in missingFields) f: ['This field is required'],
         },
       );

  @override
  List<Object?> get props => [message, code, metadata, fieldErrors, missingFields];
}

class FormatFailure extends Failure {
  const FormatFailure({
    super.message = 'Invalid format',
  }) : super(code: 'FORMAT_ERROR');
}

// ==================== RESOURCE FAILURES ====================

class NotFoundFailure extends Failure {
  final String? resource;
  final String? id;

  NotFoundFailure({
    this.resource,
    this.id,
    super.message = 'Resource not found',
  }) : super(
         code: 'NOT_FOUND',
         metadata: {
           'resource': resource,
           'id': id,
         },
       );

  factory NotFoundFailure.user(String id) => NotFoundFailure(resource: 'User', id: id, message: 'User not found');

  factory NotFoundFailure.organizer(String id) =>
      NotFoundFailure(resource: 'Organizer', id: id, message: 'Organizer not found');

  @override
  List<Object?> get props => [message, code, metadata, resource, id];
}

class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'Resource already exists',
  }) : super(code: 'CONFLICT');
}

class DuplicateFailure extends Failure {
  final String? field;

  DuplicateFailure({
    this.field,
    super.message = 'Duplicate entry',
  }) : super(
         code: 'DUPLICATE',
         metadata: field != null ? {'field': field} : null,
       );

  @override
  List<Object?> get props => [message, code, metadata, field];
}

class ResourceExhaustedFailure extends Failure {
  const ResourceExhaustedFailure({
    super.message = 'Resource limit exceeded',
  }) : super(code: 'RESOURCE_EXHAUSTED');
}

// ==================== CACHE/STORAGE FAILURES ====================

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
  }) : super(code: 'CACHE_FAILURE');
}

class CacheMissFailure extends Failure {
  final String? key;

  CacheMissFailure({
    this.key,
    super.message = 'Data not found in cache',
  }) : super(
         code: 'CACHE_MISS',
         metadata: key != null ? {'key': key} : null,
       );

  @override
  List<Object?> get props => [message, code, metadata, key];
}

class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
  }) : super(code: 'STORAGE_FAILURE');
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
  }) : super(code: 'DATABASE_FAILURE');
}

// ==================== BUSINESS LOGIC FAILURES ====================

class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    String? code,
    super.metadata,
  }) : super(code: code ?? 'BUSINESS_ERROR');
}

class InsufficientFundsFailure extends BusinessFailure {
  final double? required;
  final double? available;

  InsufficientFundsFailure({
    this.required,
    this.available,
    super.message = 'Insufficient funds',
  }) : super(
         code: 'INSUFFICIENT_FUNDS',
         metadata: {
           'required': required,
           'available': available,
         },
       );

  @override
  List<Object?> get props => [message, code, metadata, required, available];
}

class StateFailure extends BusinessFailure {
  final String currentState;
  final String attemptedAction;

  StateFailure({
    required this.currentState,
    required this.attemptedAction,
    super.message = 'Invalid operation for current state',
  }) : super(
         code: 'INVALID_STATE',
         metadata: {
           'currentState': currentState,
           'attemptedAction': attemptedAction,
         },
       );

  @override
  List<Object?> get props => [message, code, metadata, currentState, attemptedAction];
}

class QuotaExceededFailure extends BusinessFailure {
  final int? limit;
  final int? current;

  QuotaExceededFailure({
    this.limit,
    this.current,
    super.message = 'Quota exceeded',
  }) : super(
         code: 'QUOTA_EXCEEDED',
         metadata: {
           'limit': limit,
           'current': current,
         },
       );

  @override
  List<Object?> get props => [message, code, metadata, limit, current];
}

// ==================== EXTERNAL SERVICE FAILURES ====================

class ExternalServiceFailure extends Failure {
  final String? serviceName;

  ExternalServiceFailure({
    required super.message,
    this.serviceName,
  }) : super(
         code: 'EXTERNAL_SERVICE_FAILURE',
         metadata: serviceName != null ? {'service': serviceName} : null,
       );

  @override
  List<Object?> get props => [message, code, metadata, serviceName];
}

class PaymentFailure extends Failure {
  final String? transactionId;
  final String? paymentMethod;

  PaymentFailure({
    required super.message,
    this.transactionId,
    this.paymentMethod,
  }) : super(
         code: 'PAYMENT_FAILED',
         metadata: {
           'transactionId': transactionId,
           'paymentMethod': paymentMethod,
         },
       );

  @override
  List<Object?> get props => [message, code, metadata, transactionId, paymentMethod];
}

class ThirdPartyAuthFailure extends Failure {
  final String? provider;

  ThirdPartyAuthFailure({
    required super.message,
    this.provider,
  }) : super(
         code: 'THIRD_PARTY_AUTH_FAILED',
         metadata: provider != null ? {'provider': provider} : null,
       );

  @override
  List<Object?> get props => [message, code, metadata, provider];
}

// ==================== RATE LIMITING/THROTTLING ====================

class RateLimitFailure extends Failure {
  final DateTime? retryAfter;
  final int? limit;
  final int? remaining;

  RateLimitFailure({
    super.message = 'Too many requests. Please slow down.',
    this.retryAfter,
    this.limit,
    this.remaining,
  }) : super(
         code: 'RATE_LIMITED',
         metadata: {
           'retryAfter': retryAfter?.toIso8601String(),
           'limit': limit,
           'remaining': remaining,
         },
       );

  Duration? get waitDuration => retryAfter?.difference(DateTime.now());

  @override
  List<Object?> get props => [message, code, metadata, retryAfter, limit, remaining];
}

// ==================== CANCELLATION/USER ACTION ====================

class CancellationFailure extends Failure {
  const CancellationFailure({
    super.message = 'Operation was cancelled',
  }) : super(code: 'CANCELLED');
}

class UserAbortedFailure extends Failure {
  const UserAbortedFailure({
    super.message = 'User cancelled the operation',
  }) : super(code: 'USER_ABORTED');
}

// ==================== UNKNOWN/CATCH-ALL ====================

class UnknownFailure extends Failure {
  final dynamic originalError;

  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    this.originalError,
  }) : super(code: 'UNKNOWN');

  @override
  List<Object?> get props => [message, code, metadata, originalError];
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
  }) : super(code: 'UNEXPECTED');
}

// ==================== PARSING/DATA INTEGRITY ====================

class ParsingFailure extends Failure {
  final String? field;
  final dynamic value;

  const ParsingFailure({
    required super.message,
    this.field,
    this.value,
  }) : super(code: 'PARSE_ERROR');

  @override
  List<Object?> get props => [message, code, metadata, field, value];
}

class DataIntegrityFailure extends Failure {
  const DataIntegrityFailure({
    super.message = 'Data integrity violation',
  }) : super(code: 'DATA_INTEGRITY');
}

class SerializationFailure extends Failure {
  const SerializationFailure({
    super.message = 'Failed to serialize data',
  }) : super(code: 'SERIALIZATION_ERROR');
}
